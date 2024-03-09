# Splatsune's NixOS Configurations

This repository contains a Nix flake that configures my various systems with NixOS installed. This is very much a work in progress.

## Hosts

The following machines are configured by this flake:

### Desktops
- "Snatcher", my custom-built desktop PC (AMD Ryzen 9 7900X, NVidia GeForce RTX 3060)
- "Minion", an [Infinity E15-5A165-BM](https://www.infinitygaming.com.au/product/e15-5a165-bm/) gaming laptop (AMD Ryzen 5 6600H, NVidia GeForce GTX 1650)
- "Dweller", an [Acer Chromebook model C720](https://www.intel.com/content/dam/www/public/us/en/documents/brochures/acer-chromebook-c720-datasheet.pdf)

### Servers
- "Conductor", a [Lenovo ThinkCentre M90n Nano](https://www.lenovo.com/au/en/p/desktops/thinkcentre/m-series-tiny/thinkcentre-m90n-1/11tc1mnm93n) running on the home network
- "NeurarioDotCom", a Linode VPS hosting my [web server](https://neurario.com)

## To-do
- **Dweller** - map Chromebook buttons (fn media/brightness/etc keys) without losing out on F1-F12 functions
