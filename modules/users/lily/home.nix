{ config, lib, pkgs, ... }:
let
  isNixOS = config ? hostSpec;
  user = if isNixOS then config.hostSpec.userName else "lily";
in
{
  home = {
    # username = if isNixOS then user;
    # homeDirectory = if isNixOS then "/home/${user}";
    shell.enableShellIntegration = true;
    stateVersion = "25.05";
    
  };

  xdg.enable = true;

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

  # Environments
  # programs.niri = {
  #   enable = isNixOS;
  #   package = pkgs.niri-unstable;
  # };
}
