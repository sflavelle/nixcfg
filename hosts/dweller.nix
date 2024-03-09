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
  services.keyd = {
      enable = true;
      keyboards = {
          chromekb = {
              ids = [ "0001:0001" ];
              settings = {
                  main = {
                      f1 = "overload(prev, f1)";
                      f2 = "overload(next, f2)";
                      f3 = "overload(refresh, f3)";
                      f4 = "overload(f11, f4)";
                      f5 = "overload(cyclewindows, f5)";
                      f6 = "overload(brightnessdown, f6)";
                      f7 = "overload(brightnessup, f7)";
                      f8 = "overload(mute, f8)";
                      f9 = "overload(volumedown, f9)";
                      f10 = "overload(volumeup, f10)";
                  };
                  control = {
                     left = "home";
                     right = "end";
                     up = "pageup";
                     down = "pagedown";
                  };
              };
          };
      };
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  stylix.polarity = "dark";


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

