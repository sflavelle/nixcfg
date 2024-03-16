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

  # Keyboard customization
  sound.mediaKeys.enable = true;
  services.keyd = {
      enable = true;
      keyboards = {
          chromekb = {
              ids = [ "0001:0001" ];
              settings = {
                  main = {
                      f1 = "prev";
                      f2 = "next";
                      f3 = "refresh";
                      f4 = "f11";
                      f5 = "cyclewindows";
                      f6 = "brightnessdown";
                      f7 = "brightnessup";
                      f8 = "mute";
                      f9 = "volumedown";
                      f10 = "volumeup";
                  };
                  "control+alt" = {
                      f1 = "f1";
                      f2 = "f2";
                      f3 = "f3";
                      f4 = "f4";
                      f5 = "f5";
                      f6 = "f6";
                      f7 = "f7";
                      f8 = "f8";
                      f9 = "f9";
                      f10 = "f10";
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


  services.xserver.displayManager.sddm.enable = true;
  programs.hyprland.enable = true;
  programs.hyprland.package = inputs.hyprland.packages.${pkgs.system}.hyprland;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      user = "lily";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  ];


  system.stateVersion = "23.11"; # Did you read the comment?

}

