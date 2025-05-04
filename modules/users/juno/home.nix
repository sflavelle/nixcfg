{ config, lib, ... }:
{
  home = {
    username = "juno";
    homeDirectory = "/home/juno";
    shell.enableShellIntegration = true;
    stateVersion = "25.05";
    
  };

  xdg.enable = true;

  programs.fish.enable = true;

  programs.eza.enable = true;
  programs.home-manager.enable = true;
  programs.mpv.enable = true;
  programs.yazi.enable = true;

  # Configs
  programs.rclone = {
    enable = true;
  };
  programs.zoxide = {
    enable = true;
    options = ["--cmd cd"];
  };
}
