{ self, inputs, ... }: {

  flake.nixosModules.userLily = { pkgs, lib, config, ... }: let
    primEmail = "me@neurario.com";
  
  in {
    users.users."lily" = {
      isNormalUser = true;
      description = "Lily Flavelle";
      extraGroups = [ "networkmanager" "wheel" "input" "uinput" "audio" "netbird-wt0" ];
      shell = pkgs.fish;
      packages = with pkgs; [
        rclone
      ];
    };

    home-manager.users.lily = {
      home = {
        username = "lily";
        homeDirectory = "/home/lily";
        stateVersion = "26.05";
      };

      home.packages = with pkgs; [

      ];

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
        };
      };
      programs.gh = {
        enable = true;
        gitCredentialHelper.enable = true;
      };

      programs.home-manager.enable = true;

      programs.zellij.enable = true;

      programs.rbw = {
        enable = true;
        settings.base_url = "https://vault.neurario.com";
        settings.email = primEmail;
        settings.pinentry = pkgs.pinentry-gnome3;
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
                vfs-cache-mode = "writes";
                vfs-cache-max-age = "5s";
                attr-timeout = "5s";
                dir-cache-time = "5s";
              };
            };
            secrets = {
              pass = config.age.secrets.rclone-ndcfiles.path;
            };
          };
        };
      };
    };
  };

}
