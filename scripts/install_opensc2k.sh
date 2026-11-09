#!/bin/bash
# install_opensc2k.sh: download the official OpenSC2K Mac release, check its
# SHA-256 against the release's own SHA256SUMS.txt, check Apple notarization,
# and copy OpenSC2K.app into /Applications (or ~/Applications).
#
# Usage:
#   bash scripts/install_opensc2k.sh            # latest release
#   bash scripts/install_opensc2k.sh v0.3.0     # a specific release
#   OPENSC2K_DEST=~/Games bash scripts/install_opensc2k.sh   # another folder
#
# It never builds or runs anything from source. It stops if a check fails.

set -eu

REPO=OpenSC2K/OpenSC2K
TAG=${1:-}

if [ -z "$TAG" ]; then
  TAG=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
        | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -1)
  [ -n "$TAG" ] || { echo "could not look up the latest release" >&2; exit 1; }
fi
VER=${TAG#v}
DMG="OpenSC2K-$VER-macos-universal.dmg"
BASE="https://github.com/$REPO/releases/download/$TAG"

WORK=$(mktemp -d /tmp/opensc2k.XXXXXX)
cd "$WORK"
echo "Downloading OpenSC2K $TAG ..."
curl -fL --progress-bar -o "$DMG" "$BASE/$DMG"
curl -fsSL -o SHA256SUMS.txt "$BASE/SHA256SUMS.txt"

echo "Checking SHA-256 ..."
grep " $DMG\$" SHA256SUMS.txt | shasum -a 256 -c -

echo "Checking Apple notarization ..."
spctl -a -t open --context context:primary-signature -vv "$DMG" 2>&1 | tee spctl.txt
grep -q 'source=Notarized Developer ID' spctl.txt \
  || { echo "not notarized, stopping" >&2; exit 1; }

DEST=${OPENSC2K_DEST:-/Applications}   # set OPENSC2K_DEST to install somewhere else
[ -w "$DEST" ] || { DEST="$HOME/Applications"; mkdir -p "$DEST"; }

MNT=$(mktemp -d /tmp/opensc2k-dmg.XXXXXX)
hdiutil attach -readonly -nobrowse -mountpoint "$MNT" "$DMG" >/dev/null 2>&1
trap 'hdiutil detach "$MNT" >/dev/null 2>&1 || true' EXIT
[ -d "$MNT/OpenSC2K.app" ] || { echo "OpenSC2K.app not found in the DMG" >&2; exit 1; }

if [ -d "$DEST/OpenSC2K.app" ]; then
  echo "Replacing $DEST/OpenSC2K.app (your imported packs and cities are kept, they live in ~/Library)."
  mv "$DEST/OpenSC2K.app" "$WORK/OpenSC2K.app.old"
fi
ditto "$MNT/OpenSC2K.app" "$DEST/OpenSC2K.app"
spctl -a -vv "$DEST/OpenSC2K.app"

echo
echo "Installed OpenSC2K $VER to $DEST/OpenSC2K.app"
echo "Next: bash scripts/check_sc2k.sh <your SimCity 2000 folder, .iso or .zip>"
