# Contributing

Fixes and reports are welcome.

## Reporting a problem

Open an issue with the bug report template. Please include:

* your Mac model and macOS version
* the OpenSC2K version (About OpenSC2K in the app)
* which copy you imported from (CD, `.iso`, installed folder) and what `check_sc2k.sh` printed
* the console log: Cmd+Shift+J in the game, then Save

Problems inside the game engine itself belong upstream at [OpenSC2K](https://github.com/OpenSC2K/OpenSC2K/issues). This repo only covers installing it and getting your files into it.

## Pull requests

* Keep the scripts working with the `bash` that ships with macOS (3.2), with no extra installs.
* Never add game files, extracted assets or screenshots of game art. Only the OpenSC2K interface.
* Test on your own Mac before sending, and say what you tested.
