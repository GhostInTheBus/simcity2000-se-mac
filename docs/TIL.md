# TIL: SimCity 2000 Special Edition on an Apple Silicon Mac

Notes from getting SimCity 2000 SE running on an M1 Max with macOS 27, November 2026.

## The 1996 CD holds three games

The Special Edition CD (volume label `SC2KSEPC`) has three separate versions in their own folders: `DOS`, `WIN31` and `WIN95/SC2K`. The Windows 95 one is the one to use. It has the most fixes and was the only version that could run at any window size.

The `WIN95/SC2K` folder on the CD is already laid out like an installed game. You don't need to run the old installer.

## Don't trust VERSION.INF

`WIN95/SC2K/VERSION.INF` on the 1996 CD says Release 1.0, August 14 1995. The executable is newer than that. Its PE header timestamp is `0x313E706E`, March 7 1996, and that is exactly the value the sc2kfix project checks for to spot the 1996 Special Edition (their `dllmain.cpp`). The older 1995 CD Collection build has `0x302FEA8A`. `check_sc2k.sh` reads that same timestamp.

## Why the original exe struggles on modern systems

A static look at `SIMCITY.EXE`'s import table shows why:

* It draws in 8 bit color and animates the palette (`AnimatePalette`, `SetSystemPaletteUse`, `CreateDIBSection`). That's how water shimmers and traffic moves. Modern macOS and Windows don't do palette animation the old way, so it breaks.
* Timing and music go through `WINMM.dll` (`timeSetEvent`, `mciSendCommandA`). That's why sc2kfix ships as a stand in `winmm.dll`: the game loads it like the system one.
* Videos use `smackw32.dll` (Smacker), called by ordinal number.

So instead of running the 1996 exe under a compatibility layer, this setup uses OpenSC2K, a rewrite of the engine in Rust and Godot that reads the art, sounds, music and text from your copy.

## OpenSC2K import facts

* There is no command line import. It only happens in the app's own window.
* A "complete Windows installation" in OpenSC2K's terms means these files next to each other: `SIMCITY.EXE`, `WINSCURK.EXE`, `DATA/DATA_USA.DAT`, `DATA/DATA_USA.IDX`, `DATA/TEXT_USA.DAT`, `DATA/TEXT_USA.IDX`, `DATA/LARGE.DAT`, `DATA/SMALLMED.DAT`, `DATA/SPECIAL.DAT`, `BITMAPS/403.BMP`, `BITMAPS/NEIGHBOR.BMP`, `BITMAPS/PAL_MSTR.BMP`, `BITMAPS/PAL_MAC.BMP`, `SCURKART/ORIGINAL.MIF`. With all of them the import adds the city interface portraits, desktop icons and SCURK art. The 1996 CD has every one.
* The importer ignores letter case and the `;1` ISO version suffix, so a mounted CD works as is.
* Imported packs go to `~/Library/Application Support/Godot/app_userdata/OpenSC2K/packs/`. Each import makes a new folder, so a double click on Import leaves two copies.
* The original game files are only read, never changed.

## Logs

* Godot writes `logs/godot.log` in that same folder, but in the release build it stayed empty during a whole play session.
* The in game console (Cmd+Shift+J) shows the engine line (`Godot Engine v4.7.2`, `Metal 4.0`, the GPU) and counts errors and warnings. Save writes it to the logs folder.

## How it ran

* Loading the 2.3 million population sample city with arcologies everywhere: 55 to 113 FPS at the fastest sim speed (African Swallow), about 35% CPU.
* Music played (tracks 10002 and 10008), notices and the yearly budget came up on time, and the city went bankrupt on schedule because its property tax is 0%.
* Console after the run: 0 errors, 0 warnings.

## The archive.org downloads

Two items were tried. `SimCity_2000_Special_Edition_Maxis_Inc._1996` holds a `.iso` of the CD plus box scans. `msdos_SimCity_2000_SE_1995` holds an installed DOS copy for the in browser emulator. Its `SC2K.EXE` is byte for byte the one on the CD (MD5 `921112b0fa92228eb5c2231a5b92829b`). OpenSC2K can import DOS, but the Windows 95 version gives the full set, so use the `.iso`.
