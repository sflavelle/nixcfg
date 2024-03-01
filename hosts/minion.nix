# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{

  imports = [ # Include the results of the hardware scan.
    ../hardware/minion.nix
  ];

  # Seems my patch is built for 6.6
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_6;
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
  };

  boot.kernelPatches = [{
    name = "acpi quirk";
    patch = pkgs.fetchurl {
        url = "https://git.neurario.com/splatsune/nixcfg/raw/commit/87c4f04fcdc8564982fe780aa25024a54c5dada4/hardware/minion-fixirq.patch";
        hash = "sha256-Lo4QWOC2sVRsB+90uiaimuyhFXyaHgKuAeDLN+Bjb/g=";
    };
  }];

  networking.hostName = "minion"; # Define your hostname.

  services.tlp = { enable = true; };
  services.power-profiles-daemon.enable =
    lib.mkForce false; # Since TLP is enabled instead

  hardware.nvidia.prime = {
    amdgpuBusId = "PCI:5:0:0";
    nvidiaBusId = "PCI:1:0:0";
    offload.enable = true;
    offload.enableOffloadCmd = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ hplip ];

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  users.users.lily.extraGroups = [ "audio" ];
  users.users.lily.packages = (with pkgs; [
    pandoc
    # Programs
    steam-rom-manager
    lutris
    obs-studio

    # Custom Packages
    (pkgs.callPackage ../pkgs/poptracker.nix { })

  ]) ++ (with pkgs.obs-studio-plugins; [
    obs-vkcapture
    input-overlay
    obs-text-pthread
    obs-source-clone
    obs-shaderfilter
    obs-source-record
    obs-pipewire-audio-capture
  ]);

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "lily";
  };

  virtualisation.podman.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.variables = { EDITOR = "kak"; };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = with pkgs; [
    cfs-zen-tweaks
    wget
    httpie
    pandoc
    powershell
    git
    curl
    partition-manager
    gparted
    wineWowPackages.stable
    coreutils
    clang
  ];

  system.stateVersion = "23.05"; # Did you read the comment?

}
