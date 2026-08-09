{ self, inputs, ... }: {

  flake.nixosModules.userLily = { pkgs, lib, config, ... }: {
    users.users."lily" = {
      isNormalUser = true;
      description = "Lily Flavelle";
      extraGroups = [ "networkmanager" "wheel" "input" "uinput" "audio" ];
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

      programs.git = {
        enable = true;
        settings = {
          user = {
            name = "Lily Flavelle";
            email = "me@neurario.com";
          };
        };
      };
      programs.gh = {
        enable = true;
        gitCredentialHelper.enable = true;
      };

      programs.home-manager.enable = true;

      programs.zellij.enable = true;

      programs.rclone = {
        enable = true;
        remotes = {
          ndc-files = {
            config = {
              type = "webdav";
              url = "https://files.neurario.com";
              vendor = "owncloud";
              user = "splatsune";
            };
            mounts."/" = {
              enable = true;
              mountPoint = "${config.home-manager.users.lily.home.homeDirectory}/mnt/ndc-files";
              options = {

              };
            };
            # secrets = {
            #   headers = 
            # };
          };
        };
      };
    };
  };

}
