{ config, lib, pkgs, mainUser, ... }:
let
  isNixOS = config ? hostSpec;
  user = if isNixOS then mainUser else "lily";
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

  # Services
  services.mpd = {
    enable = if isNixOS then config.hostSpec.hostName == "puppetmaster" else false;
    musicDirectory = "/home/${user}/Music";
    network.listenAddress = "any";
    dbFile = "/home/${user}/.local/share/mpd/database";
    playlistDirectory = "/home/${user}/.local/share/mpd/playlists";
    extraConfig = lib.mkIf (config.hostSpec.hostname == "puppetmaster") ''
      bind_to_address "any"
      audio_output {
        type "fifo"
        name "Snapcast"
        path "/run/snapserver/mpd-${user}";
        format "48000:16:2"
        '';
  };
  services.syncthing = {
    enable = true;
    guiAddress = "0.0.0.0:8385";
  };

  # Environments
  # programs.niri = {
  #   enable = isNixOS;
  #   package = pkgs.niri-unstable;
  # };
}
