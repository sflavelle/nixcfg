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
  programs.mpv.enable = true;
  programs.yazi.enable = true;

  # Configs
  programs.rclone = {
    enable = true;
  };
}
