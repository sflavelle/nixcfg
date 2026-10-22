{ self, inputs, ... }: {

  flake.nixosModules.userLily = { pkgs, lib, config, ... }: let
    primEmail = "me@neurario.com";
  
  in {
    users.users."lily" = {
      isNormalUser = true;
      description = "Lily Flavelle";
      extraGroups = [ "networkmanager" "wheel" "input" "uinput" "audio" ];
      shell = pkgs.fish;
      linger = true;
      packages = with pkgs; [
        rclone
        discord 
        # materialgram
        imhex
      ];
    };

    home-manager.sharedModules = [
      inputs.nixcord.homeModules.nixcord
    ];

    home-manager.users.lily = {
      home = {
        username = "lily";
        homeDirectory = "/home/lily";
        stateVersion = "26.05";
      };

      home.packages = with pkgs; [
        tuisky
      ];

      systemd.user.sessionVariables = {
        EDITOR = "hx";
      };

      programs.nixcord = {
        enable = true;
        discord.enable = true;
        discord.vencord.enable = true;
        config.useQuickCss = true;
      };

      programs.fish = {
        enable = true;
        shellAliases = let
            eza = lib.getExe pkgs.eza;
          in {
            ls = eza;
            ll = "${eza} -l";
            cat = lib.getExe pkgs.bat;
            helix = "hx";
            tldr = lib.getExe pkgs.tealdeer;
          };
        shellInit = let
            confOmp = ./posh.yaml;
          in ''
          ${lib.getExe pkgs.zoxide} init --cmd cd fish | source
          ${lib.getExe pkgs.oh-my-posh} init fish -c ${confOmp} | source
        '';
      };

      programs.git = {
        enable = true;
        settings = {
          user = {
            name = "Lily Flavelle";
            email = primEmail;
          };
          pager.diff = "diffnav";
        };
      };
      programs.gh = {
        enable = true;
        gitCredentialHelper.enable = true;
      };

      programs.helix = {
        enable = true;
        defaultEditor = true;
        settings = {
          editor.soft-wrap = true;
        };
      };

      programs.home-manager.enable = true;

      programs.zellij.enable = true;

      programs.rbw = {
        enable = true;
        settings.base_url = "https://vault.neurario.com";
        settings.email = primEmail;
        settings.pinentry = pkgs.pinentry-gnome3;
      };

      programs.yazi = {
        enable = true;
        settings = {
          mgr = {
            ratio = [1 3 4];
          };
        };
        extraPackages = with pkgs; [
          glow
          ouch
        ];
      };

      programs.rclone = {
        enable = true;
        remotes = {
          ndc-files = {
            config = {
              type = "webdav";
              url = "https://files.neurario.com";
              vendor = "owncloud";
              user = "splatsune";
              # pacer-min-sleep = "0.01ms";
            };
            mounts."/" = {
              enable = true;
              mountPoint = "${config.home-manager.users.lily.home.homeDirectory}/mnt/ndc-files";
              options = {
                vfs-cache-mode = "full";
                vfs-cache-max-size = "1G";
                vfs-cache-max-age = "168h";
                attr-timeout = "5m";
                dir-cache-time = "10m";
              };
            };
            secrets = {
              pass = config.age.secrets.rclone-ndcfiles.path;
            };
          };
        };
      };

      programs.gallery-dl = {
        enable = true;
        settings = {
          extractor = {
            base-directory = "~/Pictures/gallery-dl";
          };
          downloader = {
            ytdl.module = "yt-dlp";
          };
        };
      };

      services.syncthing = {
        enable = true;
        tray.enable = true;
      };

    };
  };

}
