{ config, lib, pkgs, mainUser, ... }:
let
  isNixOS = config ? hostSpec;
  user = if !isNixOS then "lily" else user;
in
{
  home = {
    username = if !isNixOS then "lily" else user;
    homeDirectory = "/home/${user}";
    shell.enableShellIntegration = true;
    stateVersion = "25.05";
    packages = with pkgs; [
      youtube-tui
    ];
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
    extraConfig = lib.mkIf (config.hostSpec.hostName == "puppetmaster") ''
      bind_to_address "any"
      audio_output {
        type "fifo"
        name "Snapcast"
        path "/run/snapserver/mpd-${user}"
        format "48000:16:2"
        mixer_type "software"
      }
        '';
  };
  services.syncthing = {
    enable = true;
    guiAddress = "0.0.0.0:8385";
  };

  # Environments
  programs.niri = {
    enable = isNixOS;
    package = pkgs.niri-unstable;
    # settings = import ./cfg/niri.nix {
    #   inherit isNixOS;
    #   inherit mainUser;
    # };
  };
}
