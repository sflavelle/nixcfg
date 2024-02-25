{ config, lib, pkgs, ... }:

{
  networking.hostName = "conductor"; # Define your hostname.

  imports =
    [ # Include the results of the hardware scan.
      ../hardware/conductor.nix
      ../fragments/localdns.nix
    ];

  nixpkgs.config.permittedInsecurePackages = [
  	"openssl-1.1.1u"
	   "nodejs-16.20.0"
  ];

  # Hardware Configuration
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Nix Configuration
  nix = {
		daemonCPUSchedPolicy = "batch";
	};

#  fileSystems."/mnt/media" = {
#      device = "/dev/mass-storage/shared";
#      fsType = "btrfs";
#      options = [ "nofail" ];
#  };
#  fileSystems."/mnt/nextcloud" = {
#      device = "/dev/mass-storage/nextcloud";
#      fsType = "btrfs";
#      options = [ "nofail" ];
#  };
#  fileSystems."/home" = {
#      device = "/dev/mass-storage/homes";
#      fsType = "btrfs";
#      options = [ "nofail" ];
#  };

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
        enable = false;
  	allowedTCPPorts = [
  		27015
  		8123
  		80
  		8000
  		5001
  	];
	allowedUDPPorts = [ 27005 27020 ];
	extraCommands = ''
	  iptables -A nixos-fw -p tcp --source 10.0.0.0/16 -j nixos-fw-accept
	  iptables -A nixos-fw -p udp --source 10.0.0.0/16 -j nixos-fw-accept
	'';
  };

  # Network mounts

  services.samba-wsdd.enable = true;
  services.samba = {
  	enable = true;
  	openFirewall = true;
	securityType = "user";
	extraConfig = ''
		browseable = yes
		smb encrypt = required
	'';
	shares = {
		homes = {
			browseable = "no";
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lily = {
    extraGroups = [ "networkmanager" "wheel" "syncthing" ];
    packages = with pkgs; [
			filebot
			steamcmd
			tmux
    ];
  };
  users.users.juno = {
     isNormalUser = true;
     description = "Juno Trinity";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
		gh git git-crypt
		gnupg
		mosh
		powershell
		python311Packages.argcomplete
		rclone distrobox yt-dlp gallery-dl ympd
  ];

  services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      guiAddress = "0.0.0.0:8384";
  };
  users.users.syncthing.extraGroups = [ "users" ];

  services.magnetico = {
      enable = true;
      web.address = "0.0.0.0";
      web.port = 8101;
      crawler.maxNeighbors = 200;
  };
  services.transmission = {
      enable = true;
      openFirewall = true;
      openRPCPort = true;
      settings = {
          rpc-bind-address = "0.0.0.0";
          rpc-whitelist = "127.0.0.1,10.0.*.*,192.168.192.*";
          rpc-port = 8100;
          download-dir = "/mnt/media/downloads/Torrents";
      };
      downloadDirPermissions = "777";
  };

  services.mosquitto = {
  	enable = true;
	listeners = [ {
		acl = [ "pattern readwrite #" ];
		omitPasswordAuth = true;
		settings.allow_anonymous = true;
	} ];
  };

  security.acme = {
      acceptTerms = true;
      useRoot = true;
      defaults = {
          dnsProvider = "linode";
          email = "me@neurario.com";
          credentialFiles = {
              "LINODE_TOKEN_FILE" = "/etc/nixos/env/linode.token";
          };
      };
      
  };

  # Smart Home

  
  sops.templates."home-assistant-secrets.yaml" = {
  	owner = "hass";
        path = "/var/lib/hass/secrets.yaml";
        content = '' 
        	latitude: ${config.sops.placeholder.lat} 
                longitude: ${config.sops.placeholder.long} 
                elevation: ${config.sops.placeholder.elevation} 
        '';
  };
  services.home-assistant = {
        enable = true;
        openFirewall = true;
        extraComponents = [ "mqtt" "zeroconf" "whisper" "piper" "tuya" "sonos" "aussie_broadband" "calendar" "date" "datetime" "color_extractor" ];
        customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
            mushroom
            mini-media-player
        ];
        config = {
            homeassistant = {
                name = "Home";
                unit_system = "metric";
                time_zone = "Australia/Melbourne";
                latitude = "!secret latitude";
                longitude = "!secret longitude";
                elevation = "!secret elevation";
            };
        };
    };
  services.zigbee2mqtt = {
      enable = true;
      settings = {
          homeassistant = config.services.home-assistant.enable;
          permit_join = true;
          serial.port = "/dev/ttyACM0";
      };
  };

  # Containers
  virtualisation.oci-containers = {
  	backend = "podman";
  };
  virtualisation.podman = {
	   defaultNetwork.settings = { dns_enabled = true; };
  };

	# Caddy Config

	services.nginx = {
		enable = true;
		recommendedProxySettings = true;
		recommendedOptimisation = true;
		virtualHosts."home.neurario.com" = {
			default = true;
			serverAliases = [ "10.0.0.3" ];
		};
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

	# Networking Containers

	virtualisation.oci-containers.containers = {
		wyoming-whisper = {
			volumes = [ "/srv/ha-whisper:/data" ];
			image = "rhasspy/wyoming-whisper";
			ports = [ "10300:10300" ];
			cmd = [ "--model" "tiny-int8"
				"--language" "en" ];
		};
		wyoming-piper = {
			volumes = [ "/srv/ha-piper:/data" ];
			image = "rhasspy/wyoming-piper";
			ports = [ "10200:10200" ];
			cmd = [ "--voice" "en_US-lessac-medium" ];
		};
		# Misc Service Containers
		cops = {
			image = "lscr.io/linuxserver/cops:latest";
			volumes = [
				"/srv/calibre-cops:/config"
				"/home/lily/eBooks:/books"
			];
			environment = {
				PUID = "1000";
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
  system.stateVersion = "23.05"; # Did you read the comment?

}
