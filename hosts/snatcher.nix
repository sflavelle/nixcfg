# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, inputs, pkgs, ... }:

{

  hostSpec = {
    hostName = "snatcher";
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
      scale = 1.0;
    }
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;
  systemd.extraConfig = "DefaultLimitNOFILE=524288";

  networking.firewall.enable = false;

  services.beesd.filesystems = {
      home = {
          spec = "/dev/SSD/home";
          hashTableSizeMB = 8096;
          verbosity = "crit";
          extraOptions = [
              "--thread-count" "8"
              "--loadavg-target" "5.0"
          ];
		  };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ hplip ];

	programs.adb.enable = true;

  users.users."${config.hostSpec.userName}" = {
    extraGroups = [ "audio" "adbusers" ];
    packages = with pkgs; [
      keyfinder-cli
      beets-unstable
      # Programs
      steam-rom-manager
      protontricks
      godot_4
      filebot
      calibre
      via

      # Media Production
      # (davinci-resolve.override { studioVariant = true; } )
      inkscape
      reaper
      # Plugins
      yabridge

    ];
  };

  services.xserver.videoDrivers = [ "amdgpu" ];
  boot.initrd.kernelModules = [ "amdgpu" ];

  hardware.graphics.extraPackages = with pkgs; [
	  rocmPackages.clr.icd
	];

	systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];


  hardware.keyboard.qmk.enable = true;
  hardware.bluetooth.enable = true;

  programs.gamescope = {
      enable = true;
      args = [ "--fullscreen" ];
  };

  virtualisation.containers.enable = true;
  virtualisation.podman.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = with pkgs; [
    stable.davinci-resolve-studio
    pandoc
    powershell
    git
    curl
    gparted
    wineWowPackages.waylandFull
    wineasio
    coreutils

    # soundfonts
    soundfont-arachno
  ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  system.stateVersion = "23.05"; # Did you read the comment?

}
