# Acer Chromebook C720
# This project inspired by Veronica Explains video:
# https://www.youtube.com/watch?v=z6oyqrrXTLM

{ config, inputs, lib, pkgs, ... }:

{
  hostSpec = {
    hostName = "dweller";
    isPublic = true;
    isMinimal = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # This Chromebook has 16GB storage, optimise as much as we can
  nix.settings.auto-optimise-store = true;
  zramSwap = {
      enable = true;
  };

  environment.systemPackages = with pkgs; [
    ungoogled-chromium
    ghostty
    mpv yt-dlp

    # extra CLI apps
    epy 
  ];

  system.stateVersion = "24.11";

}

