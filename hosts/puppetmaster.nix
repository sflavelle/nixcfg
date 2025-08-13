{ config, lib, pkgs, ... }:

{
  hostSpec = {
    hostName = "puppetmaster";
    isServer = true;
  };

  imports = [
    # Include the results of the hardware scan.
    ../hardware/puppetmaster.nix
  ];

  nixpkgs.config.permittedInsecurePackages =
    [ "openssl-1.1.1w" "nodejs-16.20.0" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hardware Configuration
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Nix Configuration
  nix = { daemonCPUSchedPolicy = "batch"; };

  fileSystems."/mnt/media" = {
    device = "/dev/disk/by-uuid/fb34e684-d992-4ce2-95c6-f70d8f613997";
    fsType = "btrfs";
    options = [ "nofail" ];
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/e368cad6-5bae-4448-874b-ebf90a1d713f";
    fsType = "btrfs";
    options = [ "nofail" ];
  };

  # Enable networking
  networking = {
    enableIPv6 = true;
    interfaces.eno2.useDHCP = lib.mkDefault true;
    dhcpcd.enable = true;
    resolvconf.enable = true;
    networkmanager.enable = true;
    nameservers = [ "8.8.8.8" "1.1.1.1" ];
    search = [ "local" ];
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 27015 8123 80 8000 5001 ];
    allowedUDPPorts = [ 27005 27020 ];
    extraCommands =
      "  iptables -A nixos-fw -p tcp --source 10.0.0.0/16 -j nixos-fw-accept\n  iptables -A nixos-fw -p udp --source 10.0.0.0/16 -j nixos-fw-accept\n";
  };

  # Network mounts

  services.samba-wsdd.enable = true;
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        security = "user";
        "unix password sync" = "yes";
      };
      homes = {
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
      };
      media = {
        path = "/mnt/media";
        "guest ok" = "yes";
        browseable = "yes";
        comment = "Shared Media Drive";
      };
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gh
    git
    mosh
    rclone
    distrobox
    yt-dlp
    gallery-dl
    ympd
    filebot
  ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    socketActivation = false;
    systemWide = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.mosquitto = {
    enable = true;
    listeners = [{
      acl = [ "pattern readwrite #" ];
      omitPasswordAuth = true;
      settings.allow_anonymous = true;
    }];
  };



  # Smart Home

  virtualisation.oci-containers.containers.homeassistant = {
    volumes = [ "/srv/home-assistant:/config" ];
    environment.TZ = "Australia/Melbourne";
    image = "ghcr.io/home-assistant/home-assistant:2025.8.1";
    extraOptions = [
      "--network=host"
      "--device=/dev/ttyACM0"
    ];
  };

  # Containers
  virtualisation.oci-containers = { backend = "podman"; };
  virtualisation.podman = {
    defaultNetwork.settings = { dns_enabled = true; };
  };

  # Media Services

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
  systemd.services.jellyfin = {
    serviceConfig = {
      CPUQuota = "70%";
      Restart = lib.mkForce "on-success";
    };
  };
  services.navidrome = {
    enable = true;
    user = "lily";
    settings.MusicFolder = "/home/lily/Music";
    settings.Address = "0.0.0.0";
    openFirewall = true;
  };

  # Networking Containers

  virtualisation.oci-containers.containers = {
    esphome = {
      image = "ghcr.io/esphome/esphome:2025.7.3";
      volumes = [
        "/srv/esphome:/config"
        "/etc/localtime:/etc/localtime:ro"
      ];
      ports = [ "6052:6052" ];
      extraOptions = [
        "--network=host"
        "--device=/dev/ttyUSB0"
      ];
    };
    # wyoming-whisper = {
    #   volumes = [ "/srv/ha-whisper:/data" ];
    #   image = "rhasspy/wyoming-whisper";
    #   ports = [ "10300:10300" ];
    #   cmd = [ "--model" "tiny-int8" "--language" "en" ];
    # };
    # wyoming-piper = {
    #   volumes = [ "/srv/ha-piper:/data" ];
    #   image = "rhasspy/wyoming-piper";
    #   ports = [ "10200:10200" ];
    #   cmd = [ "--voice" "en_US-lessac-medium" ];
    # };
    # Misc Service Containers
    cops = {
      image = "lscr.io/linuxserver/cops:latest";
      volumes = [ "/srv/calibre-cops:/config" "/home/lily/Calibre Library:/books" ];
      environment = {
        PUID = "1001";
        PGID = "100";
        TZ = "Australia/Melbourne";
      };
      ports = [ "8083:80" ];
    };
  };

  services.fwupd.enable = true;
  services.earlyoom.enable = true;

  # NetworkManager has a sstrange issue where it waits for a connection,
  # even if it's already online, and times out
  # This should help
  systemd.services.NetworkManager-wait-online = {
    serviceConfig.ExecStart = [ "" "${pkgs.networkmanager}/bin/nm-online -q" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
