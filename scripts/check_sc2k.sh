#!/bin/bash
# check_sc2k.sh: find the Windows 95 SimCity 2000 files on your own copy,
# check they are complete enough for a full OpenSC2K import, tell you which
# build you have, and copy the folder path to the clipboard for the importer.
#
# Usage:
#   bash scripts/check_sc2k.sh <folder | disc.iso | archive.zip>
#
# Works with: the CD itself, an extracted copy of the CD, an installed
# Windows 95 game folder, a .iso of the CD, or a .zip that has the .iso inside.
# Nothing is changed. An .iso stays mounted (read only) so you can import from
# it; eject it when the import is done.

set -u

die() { printf 'error: %s\n' "$*" >&2; exit 1; }

[ $# -eq 1 ] || die "give one path: a folder, a .iso or a .zip"
SRC=$1
[ -e "$SRC" ] || die "not found: $SRC"

lower() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

mount_iso() {
  mnt=$(mktemp -d /tmp/sc2k-cd.XXXXXX)
  hdiutil attach -readonly -nobrowse -mountpoint "$mnt" "$1" >/dev/null 2>&1 \
    || die "could not mount $1"
  printf '%s' "$mnt"
}

case "$(lower "$SRC")" in
  *.zip)
    iso=$(unzip -Z1 "$SRC" | grep -i '\.iso$' | head -1)
    [ -n "$iso" ] || die "no .iso inside $SRC"
    tmp=$(mktemp -d /tmp/sc2k-zip.XXXXXX)
    echo "Unpacking $iso ..."
    unzip -q -j "$SRC" "$iso" -d "$tmp" || die "unzip failed"
    ROOT=$(mount_iso "$tmp/$(basename "$iso")")
    echo "Mounted the disc image at $ROOT (the unpacked .iso is in $tmp)"
    ;;
  *.iso)
    ROOT=$(mount_iso "$SRC")
    echo "Mounted the disc image at $ROOT"
    ;;
  *)
    [ -d "$SRC" ] || die "$SRC is not a folder, .iso or .zip"
    ROOT=$SRC
    ;;
esac

# The Windows 95 game lives in WIN95/SC2K on the Special Edition CD, or at the
# top of an installed copy. Prefer WIN95 when a disc holds several versions.
exe=$(find "$ROOT" -maxdepth 4 -ipath '*win95*' -iname 'simcity.exe' 2>/dev/null | head -1)
[ -n "$exe" ] || exe=$(find "$ROOT" -maxdepth 4 -iname 'simcity.exe' 2>/dev/null | head -1)
[ -n "$exe" ] || die "no SIMCITY.EXE (the Windows 95 version) under $ROOT"
GAME=$(cd "$(dirname "$exe")" && pwd)
echo "Windows 95 game folder: $GAME"
echo

# Files OpenSC2K needs for a complete Windows import (from its
# docs/media-pack-format.md, "Import original game files").
missing=0
for rel in SIMCITY.EXE WINSCURK.EXE \
  DATA/DATA_USA.DAT DATA/DATA_USA.IDX DATA/TEXT_USA.DAT DATA/TEXT_USA.IDX \
  DATA/LARGE.DAT DATA/SMALLMED.DAT DATA/SPECIAL.DAT \
  BITMAPS/403.BMP BITMAPS/NEIGHBOR.BMP BITMAPS/PAL_MSTR.BMP BITMAPS/PAL_MAC.BMP \
  SCURKART/ORIGINAL.MIF; do
  hit=$(find "$GAME" -maxdepth 2 -ipath "$GAME/$rel" 2>/dev/null | head -1)
  if [ -n "$hit" ] && [ -s "$hit" ]; then
    printf '  ok       %s\n' "$rel"
  else
    printf '  MISSING  %s\n' "$rel"; missing=$((missing + 1))
  fi
done
echo

# The build is told apart by the PE header timestamp of SIMCITY.EXE, the same
# check the sc2kfix project uses. VERSION.INF on the 1996 CD still says 1995,
# so it is not a reliable guide.
lfanew=$(od -An -tu4 -j 60 -N 4 "$exe" | tr -d ' ')
stamp=$(od -An -tx4 -j $((lfanew + 8)) -N 4 "$exe" | tr -d ' ')
case "$stamp" in
  313e706e) build="1996 Special Edition (best: the most complete import)" ;;
  302fea8a) build="1995 CD Collection (works, but older)" ;;
  3103b687) build="Interactive Demo (partial)" ;;
  *)        build="unknown build (timestamp 0x$stamp)" ;;
esac
echo "SIMCITY.EXE build: $build"

if [ $missing -eq 0 ]; then
  echo "All files for a complete Windows import are there."
else
  echo "$missing file(s) missing. The import still runs, but some interface art and SCURK art will be absent."
fi

printf '%s' "$GAME" | pbcopy 2>/dev/null && echo "Folder path copied to the clipboard."
echo
echo "Next: open OpenSC2K, click Import Assets, then Import Original Assets,"
echo "paste the path into the game folder field, keep all four boxes ticked, Import."
case "$(lower "$SRC")" in
  *.iso|*.zip) echo "When it says Import complete, eject the disc: hdiutil detach \"$ROOT\"" ;;
esac
