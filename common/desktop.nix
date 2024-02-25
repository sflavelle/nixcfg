{ config, lib, pkgs, ... }:

{

  imports =
    [
      ./all.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "dm-mirror" ];
  boot.kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  nixpkgs.config.input-fonts.acceptLicense = true;
  fonts.packages = with pkgs; [
    font-awesome input-fonts
    xkcd-font ultimate-oldschool-pc-font-pack
    eunomia monaspace _3270font
    comic-relief comic-mono
  ];

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = lib.mkDefault false;
  services.xserver.displayManager.autoLogin.user = "lily";

  hardware.opengl.setLdLibraryPath = true;
  hardware.opengl = { enable = true; driSupport = true; };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;

  # Realtime Kernel
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  environment.systemPackages = with pkgs; [
      simple-mtpfs 
  ];


  services.flatpak.enable = true;
  hardware.steam-hardware.enable = true;

  programs.firefox = {
      enable = true;
      nativeMessagingHosts.packages = with pkgs; [ ff2mpv ];
  };

  programs.kdeconnect.enable = true;

  services.zerotierone = {
      enable = true;
      joinNetworks = [ "a84ac5c10a91ecb1" ];
    };

}
