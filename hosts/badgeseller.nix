{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../hardware/badgeseller.nix
    ];

  boot.kernelParams = [
      "acpi_backlight=native"
      "mem_sleep_default=s2idle"
  ];

  networking.hostName = "badgeseller"; # Define your hostname.
  networking.networkmanager.wifi.macAddress = "permanent";
  networking.networkmanager.wifi.scanRandMacAddress = false;
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  hardware.bluetooth.enable = true;
  hardware.facetimehd.enable = true;
  programs.light.enable = true;
  hardware.brillo.enable = true;
  #  services.hardware.pommed.enable = true; # MacBookAir9,1 is unknown???
  services.mbpfan.enable = true;
  hardware.apple-t2.enableAppleSetOsLoader = true;

  system.stateVersion = "24.05"; # Did you read the comment?

}

