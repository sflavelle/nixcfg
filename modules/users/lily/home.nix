{ config, lib, ... }:
{
  home = {
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
