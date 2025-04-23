# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, inputs, pkgs, ... }:

{

  hostSpec = {
    hostName = "snatcher";
  };

  # boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;
  systemd.extraConfig = "DefaultLimitNOFILE=524288";

  networking.firewall.enable = false;

  fileSystems = {
    "/home" = {
      device = "/dev/userdata/userhome";
      fsType = "btrfs";
    };
  };

  services.beesd.filesystems = {
      home = {
          spec = "/dev/mapper/userdata-userhome";
          hashTableSizeMB = 8096;
          verbosity = "crit";
          extraOptions = [
              "--thread-count" "4"
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

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "lily";
  };

  programs.gamescope = {
      enable = true;
      args = [ "--fullscreen" ];
  };

  services.ollama = {
      enable = true;
      acceleration = "rocm";
  };

  virtualisation.containers.enable = true;
  virtualisation.podman.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = with pkgs; [
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
