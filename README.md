# Splatsune's NixOS Configurations

This repository contains a Nix flake that configures my various systems with NixOS installed. This is very much a work in progress.

## Hosts

The following machines are configured by this flake:

### Desktops
- "Snatcher", my custom-built desktop PC (AMD Ryzen 9 7900X, AMD Radeon RX 6600)
- "Minion", an [Infinity E15-5A165-BM](https://www.infinitygaming.com.au/product/e15-5a165-bm/) gaming laptop (AMD Ryzen 5 6600H, NVidia GeForce GTX 1650)
- "Dweller", an [Acer Chromebook model C720](https://www.intel.com/content/dam/www/public/us/en/documents/brochures/acer-chromebook-c720-datasheet.pdf)
- "BadgeSeller", an [Apple MacBook Air 2019](https://support.apple.com/en-au/111948)

### Servers
- "Conductor", a [Lenovo ThinkCentre M90n Nano](https://www.lenovo.com/au/en/p/desktops/thinkcentre/m-series-tiny/thinkcentre-m90n-1/11tc1mnm93n) running on the home network
- "NeurarioDotCom", a Linode VPS hosting my [web server](https://neurario.com)

## To-do
- **BadgeSeller**: sort out suspend mode, and wifi breaking after a while
- **Dweller**: upgrade storage from 16gb stock (currently very limiting)
- **Minion**: find ways to optimise battery usage when not using graphics (figure out NVidia PRIME?)
- migrate thegeneral.chat VPS to NixOS (reqs: Mastodon, Archipelago WebHost, Matrix, Sanford Discord Bot)
- **Packages**
	- Poptracker: Fix issue with tinyfiledialogs library not detecting chosen dialog executable (maybe hardcode?)
	- Archipelago: setup package of binary (alt. help figure out [building from source](https://github.com/Ijwu/ap-nix))
