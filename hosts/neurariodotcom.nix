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
    python312Packages.pelican
  ];

  # Web Services.

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "me+acme@neurario.com";

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
  };

  services.uptime-kuma = {
    enable = true;
    settings.PORT = "4000";
  };

  services.node-red.enable = true;
  services.node-red.port = 42069;
  services.node-red.withNpmAndGcc = true;
  services.node-red.openFirewall = true;

  services.dendrite = {
      # Matrix
      enable = true;
      loadCredential = [
          "private_key:/home/lily/matrix_key.pem"
      ];
      settings = {
          global.server_name = "chat.neurario.com";
          # global.well_known_server_name = "neurario.com:8443";
          global.private_key = "$CREDENTIALS_DIRECTORY/private_key";

          client_api.registration_shared_secret = "Schizm For Dummies";

          mscs.mscs = [ "msc2836" ];
      };
  };

  services.forgejo = {
    enable = true;
    lfs.enable = true;
    settings.server.DOMAIN = "git.neurario.com";
    settings.server.ROOT_URL = "https://git.neurario.com";
  };

  # Container proxies
  services.nginx.virtualHosts = {
    "neurario.com" = {
        root = "/home/lily/repos/ndc";
        default = true;
    };
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
    "chat.neurario.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
            proxyPass = "http://127.0.0.1:8008";
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
  networking.firewall.allowedTCPPorts = [ 443 80 18080 8008 8448 ];
  networking.firewall.allowedUDPPorts = [ ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  system.stateVersion = "23.05"; # Did you read the comment?

}
