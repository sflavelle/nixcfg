# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ../hardware/neurariodotcom.nix
  ];

  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = false;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.kernelParams = [ "systemd.unified_cgroup_hierarchy=1" ];

  networking.hostName = "neurario-dot-com"; # Define your hostname.
  networking.usePredictableInterfaceNames = false;
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;

  environment.systemPackages = with pkgs; [
    inetutils
    mtr
    sysstat
    tzdata
    curl
    eza
    fd
    fzf
    htop
    killall
    wget
    git
    mosh
    php
    rclone
    neovim
    helix
    writefreely
  ];

  # Web Services.

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "me+acme@neurario.com";

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureUsers = [
      {
        name = "writefreely";
        ensurePermissions = { "writefreely.*" = "ALL PRIVILEGES"; };
      }
      { name = "splatsune"; }
    ];
    ensureDatabases = [ "writefreely" ];
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    virtualHosts."neurario.com" = { enableACME = lib.mkForce true; };
  };

  services.uptime-kuma = {
    enable = true;
    settings.PORT = "4000";
  };

  services.node-red.enable = true;
  services.node-red.port = 42069;
  services.node-red.withNpmAndGcc = true;
  services.node-red.openFirewall = true;

  services.writefreely = {
    enable = true;
    host = "neurario.com";
    nginx.enable = true;
    nginx.forceSSL = true;
    settings = {
      app.single_user = true;
      app.federation = true;
      app.site_name = "Head in Space";
    };
    database = {
      type = "mysql";
      passwordFile = "/.secrets/writefreelydb";
      createLocally = true;
    };
    admin.name = "Splatsune";
  };

  services.forgejo = {
    enable = true;
    dump.enable = true;
    lfs.enable = true;
    settings.server.DOMAIN = "git.neurario.com";
    settings.server.ROOT_URL = "https://git.neurario.com";
  };

  # Container proxies
  services.nginx.virtualHosts = {
    "git.neurario.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${
            toString config.services.gitea.settings.server.HTTP_PORT
          }";
      };
    };
    "status.neurario.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${
            toString config.services.uptime-kuma.settings.PORT
          }";
        proxyWebsockets = true;
      };
    };
    "files.neurario.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        root = "/srv/filehost";
        extraConfig = "	autoindex on;\n	autoindex_exact_size off;\n";
      };
    };
    "ntdis.neurario.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:21011";
        basicAuth = { neutopia = "meep"; };
      };
    };
  };

  virtualisation.podman.enable = true;
  virtualisation.oci-containers.containers = {
    "neutopiadiscord-archive" = {
      image = "slada/dcef:main";
      volumes = [
        "dcef_cache:/dcef/cache"
        "${/home/lily/NeutopiaDiscordExport}:/dcef/exports"
      ];
      ports = [ "21011:21011" ];
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 443 80 18080 ];
  networking.firewall.allowedUDPPorts = [ ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  system.stateVersion = "23.05"; # Did you read the comment?

}
