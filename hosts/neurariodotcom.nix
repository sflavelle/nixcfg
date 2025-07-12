# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, lib, pkgs, ... }:

{

  hostSpec = {
    hostName = "NDC";
    isServer = true;
  };

  imports = [
    # Include the results of the hardware scan.
    ../hardware/neurariodotcom.nix
  ];

  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = false;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.kernelParams = [ "systemd.unified_cgroup_hierarchy=1" ];

  networking.usePredictableInterfaceNames = false;
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;

  environment.systemPackages = with pkgs; [
    inetutils
    mtr
    sysstat
  ];

  # Web Services.

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "me+acme@neurario.com";



  virtualisation.podman.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  system.stateVersion = "25.05"; # Did you read the comment?

}
