{ self, inputs, ... }: {

  flake.nixosModules.userLily = { pkgs, lib, ... }: {
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

      programs.home-manager.enable = true;

      programs.zellij.enable = true;
    };
  };

}
