# Disc images and archive.org downloads

## A .iso of the CD

You don't need to unpack it. `check_sc2k.sh` mounts it read only with `hdiutil` and points at `WIN95/SC2K` on it:

```sh
bash scripts/check_sc2k.sh "SimCity 2000 - Special Edition (Maxis, Inc.)(1996).ISO"
```

Or mount it yourself by double clicking it in Finder, then import from the mounted disc's `WIN95/SC2K` folder.

Eject it after the import says complete. OpenSC2K keeps its own copies of everything it imported.

## The archive.org zip

The `SimCity_2000_Special_Edition_Maxis_Inc._1996` item downloads as a zip with the `.iso` inside plus scans and metadata. Hand the zip straight to the script. It unpacks only the `.iso` to a temp folder and mounts it:

```sh
bash scripts/check_sc2k.sh SimCity_2000_Special_Edition_Maxis_Inc._1996.zip
```

## bin/cue or other formats

Convert to a plain `.iso` first, or mount it with any tool you like, then point the script at the mounted folder.

## An installed Windows copy

If you have a Windows 95 install (from an old PC, or a Wine prefix), point the script at the folder with `SIMCITY.EXE` in it. That works as well as the CD.
