{ config, lib, pkgs, ... }:

{

  imports =
    [
      ./all.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.timeout = 2;

  services.xserver.enable = lib.mkDefault false;

  systemd.enableEmergencyMode = false;

}
