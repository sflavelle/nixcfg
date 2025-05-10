{ config, lib, pkgs, mainUser, nixgl ? null, ... }:
let
  isNixOS = config ? hostSpec;
  user = if !isNixOS then "lily" else mainUser;

  nixGLConfig = if nixgl != null && !isNixOS then {
    packages = import nixgl { inherit pkgs; };
    defaultWrapper = "mesa"; # or the driver you need
    installScripts = [ "mesa" ];
  } else {};
in
{
  nixGL = nixGLConfig;

  home = {
    username = if !isNixOS then "lily" else user;
    homeDirectory = "/home/${user}";
    shell.enableShellIntegration = true;
    stateVersion = "25.05";
    packages = with pkgs; [
      xwayland-satellite
      # youtube-tui
      pipe-viewer

    ];
  };

  xdg.enable = true;

  programs.eza.enable = true;
  programs.home-manager.enable = true;
  programs.mpv.enable = true;
  programs.mpv.package = if nixGLConfig != null && config.lib ? nixGL then config.lib.nixGL.wrap pkgs.mpv else pkgs.mpv;
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
    enable = isNixOS && !config.hostSpec.isServer;
    package = pkgs.niri-unstable;
    settings = import ./cfg/niri.nix {
      inherit isNixOS;
      inherit mainUser;
    };
  };
}
