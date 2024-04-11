{ config, inputs, lib, pkgs, ... }:

{

  imports = [ ./all.nix ];

  # Bootloader.
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "dm-mirror" ];
  boot.kernel.sysctl = { "vm.max_map_count" = 2147483642; };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  security.pam.services.hyprlock = {};
  security.pam.services.swaylock = {};

  nixpkgs.config = {
      input-fonts.acceptLicense = true;
      firefox.speechSynthesisSupport = false;
  };
  fonts.packages = with pkgs; [
    font-awesome
    xkcd-font
    eunomia
    monaspace
    _3270font
    comic-relief
    comic-mono
  ];

  services.greetd = {
      enable = true;
      restart = true;
      settings = {
          default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet -r -c 'sway' -t";
      };
  };

  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      swaysome swayosd swaylock
    ];
  };

  hardware.opengl.setLdLibraryPath = true;
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = lib.mkDefault false;

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
      simple-mtpfs pavucontrol libnotify
      xwaylandvideobridge
      (callPackage ../pkgs/rquickshare.nix {})
  ];

  services.flatpak.enable = true;
  hardware.steam-hardware.enable = true;

  services.zerotierone = {
    enable = true;
    joinNetworks = [ "a84ac5c10a91ecb1" ];
  };

}
