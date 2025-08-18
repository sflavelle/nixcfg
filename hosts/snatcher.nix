# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, inputs, pkgs, ... }:

{

  hostSpec = {
    hostName = "snatcher";
    isAutoStyled = true;
    wallpaper = pkgs.fetchurl {
      url = "https://w.wallhaven.cc/full/j3/wallhaven-j3d79p.jpg"; # Windows XP 'Bliss' (21:9 edit)
      hash = "sha256-2kiQ27iRSiubgAeRxLDlw1K4EFwbGs8YqrMZjjjXWzg=";
    };
  };
  monitors = [
    {
      name = "DP-2"; # KOGAN AUSTRALIA PTY LTD KAMN34RQUCSA Unknown
      primary = true;
      width = 3440;
      height = 1440;
      refreshRate = 144;
      x = 1920;
      y = 0;
      scale = 1.0;
    }
    {
      name = "DP-1"; # Philips Consumer Electronics Company PHL 216V6 ZV01929011836
      width = 1920;
      height = 1080;
      refreshRate = 60;
      x = 0;
      y = 320;
      scale = 1.0;
    }
    {
      name = "HDMI-A-2"; # Microstep MSI G24C6 0x00000243
      width = 1920;
      height = 1080;
      refreshRate = 60;
      x = 5360;
      y = 320;
      scale = 1.0;
    }
    {
      name = "HDMI-A-1"; # Graphica Computer HD Display Unknown
      width = 1920;
      height = 720;
      refreshRate = 60;
      x = 2780;
      y = 1440;
      scale = 1.25;
    }
  ];

  stylix.polarity = "light";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;
  systemd.settings.Manager = {
    DefaultLimitNOFILE = 524288;
  };

  networking.firewall.enable = false;

  # services.beesd.filesystems = {
  #     home = {
  #         spec = "/dev/SSD/home";
  #         hashTableSizeMB = 8096;
  #         verbosity = "crit";
  #         extraOptions = [
  #             "--thread-count" "8"
  #             "--loadavg-target" "5.0"
  #         ];
  # 	  };
  # };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ hplip ];

  programs.adb.enable = true;

  users.users."${config.hostSpec.userName}" = {
    extraGroups = [ "audio" "adbusers" ];
    packages = with pkgs; [
      keyfinder-cli
      stable.beets-unstable # lol, lmao
      # Programs
      protontricks
      filebot
      bottles
      vial

      (calibre.overrideAttrs ({ propagatedBuildInputs ? [ ], ... }: {
        propagatedBuildInputs = propagatedBuildInputs ++ [ pkgs.python3Packages.brotli ];
      }))

      # Game Utils
      godot
      # slade

      # Media Production
      inkscape
    ];
  };

  services.xserver.videoDrivers = [ "amdgpu" ];
  boot.initrd.kernelModules = [ "amdgpu" ];

  hardware = {
    keyboard.qmk.enable = true;
    bluetooth.enable = true;

    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
        # amdvlk
        # driversi686Linux.amdvlk
      ];
    };
    # amdgpu.amdvlk = {
    #   enable = true;
    #   support32Bit.enable = true;
    # };
  };

  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  programs.gamescope = {
    enable = true;
    args = [ "--fullscreen" ];
  };

  programs.opengamepadui = {
    enable = true;
    gamescopeSession.enable = true;
    inputplumber.enable = true;
    powerstation.enable = true;
  };

  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-ndi
      obs-vkcapture
      obs-teleport
      input-overlay
      obs-text-pthread
      obs-source-clone
      obs-shaderfilter
      obs-source-record
      obs-composite-blur
      obs-pipewire-audio-capture
    ];
  };

  virtualisation.containers.enable = true;
  virtualisation.podman.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = with pkgs; [
    # stable.davinci-resolve-studio
    pandoc
    powershell
    git
    curl
    gparted
    wineWowPackages.waylandFull
    wineasio
    coreutils

    labwc # Some programs don't play nicely with Niri, so we can nest them inside labwc

    gpu-screen-recorder
    gpu-screen-recorder-gtk

    blender-hip

    winetricks
    q4wine
    protontricks
    sidequest

    # soundfonts
    soundfont-arachno
  ];

  # Postgres dev
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17_jit;
    ensureUsers = [
      {
        name = "lily";
        ensureDBOwnership = true;
        ensureClauses.login = true;
        ensureClauses.createdb = true;
      }
    ];
    ensureDatabases = [
      "lily"
    ];
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  system.stateVersion = "23.05"; # Did you read the comment?

}
