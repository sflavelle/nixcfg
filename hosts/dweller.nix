# Acer Chromebook C720
# This project inspired by Veronica Explains video:
# https://www.youtube.com/watch?v=z6oyqrrXTLM

{ config, lib, pkgs, ... }:

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

  # Keyboard customization
  sound.mediaKeys.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  services.xserver.displayManager.lightdm.enable = true;
  programs.sway.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  ];


  system.stateVersion = "23.11"; # Did you read the comment?

}

