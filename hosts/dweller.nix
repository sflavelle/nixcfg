# Acer Chromebook C720
# This project inspired by Veronica Explains video:
# https://www.youtube.com/watch?v=z6oyqrrXTLM

{ config, inputs, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../hardware/dweller.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dweller"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # This Chromebook has 16GB storage, optimise as much as we can
  nix.settings.auto-optimise-store = true;
  zramSwap = {
      enable = true;
  };

  users.users.splatsune = {
    isNormalUser = true;
    description = "Simon Flavelle";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
    ];
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

