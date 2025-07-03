{ config, lib, pkgs, ... }:

{
  hostSpec = {
    hostName = "badgeseller";
    isPublic = true;
    hasWifi = true;
  };
  monitors = [
    {
      name = "eDP-1";
      primary = true;
      width = 2560;
      height = 1440;
      refreshRate = 60;
      x = 0;
      y = 0;
      scale = 1.5;
    }
  ];

  boot.blacklistedKernelModules = [
    "hci_bcm4377" # Bluetooth module interferes with the wifi
  ];

  imports =
    [ # Include the results of the hardware scan.
      ../hardware/badgeseller.nix
    ];

  boot.kernelParams = [
      "acpi_backlight=native"
      "mem_sleep_default=s2idle"
  ];

  boot.loader.systemd-boot = {
    enable = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.wifi.macAddress = "permanent";
  networking.networkmanager.wifi.scanRandMacAddress = false;
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  hardware.bluetooth.enable = true;
  hardware.facetimehd.enable = true;

  hardware.apple-t2 = {
    enableIGPU = true;
    firmware.enable = true;
    
  };

  system.stateVersion = "25.05"; # Did you read the comment?

}

