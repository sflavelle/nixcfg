# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, inputs, pkgs, ... }:

{

  imports = [ # Include the results of the hardware scan.
    ../hardware/snatcher.nix
  ];

  # boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;
  systemd.extraConfig = "DefaultLimitNOFILE=524288";

  networking.hostName = "snatcher"; # Define your hostname.
  networking.firewall.enable = false;

  fileSystems = {
    "/home" = {
      device = "/dev/userdata/userhome";
      fsType = "btrfs";
    };
    "/mnt/nas/home" = {
      device = "//10.0.0.3/media";
      fsType = "cifs";
      options = [
        "uid=1000"
        "gid=100"
        "_netdev"
        "x-systemd.automount"
        "credentials=/home/lily/.smb-nas"
      ];
    };
    "/mnt/nas/shared" = {
      device = (builtins.replaceStrings [ " " ] [ "\\040" ] "//10.0.0.3/media");
      fsType = "cifs";
      options = [
        "uid=1000"
        "gid=100"
        "_netdev"
        "x-systemd.automount"
        "credentials=/home/lily/.smb-nas"
      ];
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
	
  users.users.lily.extraGroups = [ "audio" "adbusers" ];
  users.users.lily.packages = (with pkgs; [
    keyfinder-cli
    beets-unstable
    # Programs
    steam-rom-manager
    protontricks
    bitwig-studio
    godot_4
    via

    # Media Production
    (davinci-resolve.override { studioVariant = true; } )
    inkscape
    reaper
    # Plugins
    yabridge

    gzdoom

    # Custom Packages
    (pkgs.callPackage ../pkgs/poptracker.nix { })

  ]);

  services.xserver.videoDrivers = [ "amdgpu" ];
  boot.initrd.kernelModules = [ "amdgpu" ];

  hardware.opengl.extraPackages = with pkgs; [
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
  environment.variables = { 
    EDITOR = "kak";
    };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = with pkgs; [
    (davinci-resolve.override { studioVariant = true; } )
    
    wget
    httpie
    pandoc
    powershell
    git
    curl
    partition-manager
    gparted
    wineWowPackages.waylandFull
    wineasio
    coreutils
    clang

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
