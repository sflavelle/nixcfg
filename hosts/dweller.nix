# Acer Chromebook C720
# This project inspired by Veronica Explains video:
# https://www.youtube.com/watch?v=z6oyqrrXTLM

{ config, inputs, lib, pkgs, ... }:

{
  hostSpec = {
    hostName = "dweller";
    isPublic = true;
    isMinimal = true;
    hasWifi = true;
    hasBattery = true;
  };
  monitors = [
    {
      name = "eDP-1";
      primary = true;
      width = 1920;
      height = 1080;
      refreshRate = 120;
      x = 0;
      y = 0;
      scale = 1.0;
    }
  ];

  imports = [
    ../hardware/dweller.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # This Chromebook has 128GB storage now, optimise as much as we can
  nix.settings.auto-optimise-store = true;
  nix.extraOptions = ''
    download-buffer-size = ${builtins.toString (128 * 1024 * 1024)}
    '';
  # Especially memory (2GB)
  zramSwap = {
      enable = true;
      algorithm = "zstd";
  };
  swapDevices = [
    {
      device = "/.swap";
      size = 1 * 1024; # 2GB
    }
  ];

  environment.systemPackages = with pkgs; [
    ungoogled-chromium
    ghostty
    mpv yt-dlp

    # extra CLI apps
    epy 
  ];

  system.stateVersion = "24.11";

}

