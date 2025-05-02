{ config, lib, ... }:
{
  home = {
    username = "lily";
    homeDirectory = "/home/lily";
    shell.enableShellIntegration = true;
    stateVersion = "25.05";
    
  };

  programs.fish.enable = true;

  programs.eza.enable = true;
  programs.home-manager.enable = true;
  programs.mpv.enable = true;
  programs.yazi.enable = true;

  # Configs
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        blur = true;
        opacity = 0.8;
      };
    };
  };
  programs.rclone = {
    enable = true;
  };
  programs.zoxide = {
    enable = true;
    options = ["--cmd cd"];
  };
}
