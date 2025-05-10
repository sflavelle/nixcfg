{ config, lib, pkgs, mainUser, inputs, nixgl ? null, ... }:
let
  isNixOS = config ? hostSpec;
  user = if !isNixOS then "lily" else mainUser;

  nixGLConfig = if nixgl != null && !isNixOS then {
    packages = import nixgl { inherit pkgs; };
    defaultWrapper = "mesa"; # or the driver you need
    installScripts = [ "mesa" ];
  } else {};

  defaultConfig = {
    hostSpec = {
      hostName = "noHost";
      isServer = false;
      isMinimal = false;
      isHandheld = false;
    };
    lib = lib;
  };

  effectiveConfig = if isNixOS then config else lib.mkMerge [ defaultConfig config ];
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
  programs.mpv.package = if nixGLConfig != null && effectiveConfig.lib ? nixGL then effectiveConfig.lib.nixGL.wrap pkgs.mpv else pkgs.mpv;
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
    enable = if effectiveConfig ? hostSpec then effectiveConfig.hostSpec.hostName == "puppetmaster" else false;
    musicDirectory = "/home/${user}/Music";
    network.listenAddress = "any";
    dbFile = "/home/${user}/.local/share/mpd/database";
    playlistDirectory = "/home/${user}/.local/share/mpd/playlists";
    extraConfig = lib.mkIf (effectiveConfig.hostSpec.hostName == "puppetmaster") ''
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
    enable = isNixOS && !effectiveConfig.hostSpec.isServer;
    package = pkgs.niri-unstable;
    settings = import ./cfg/niri.nix {
      inherit lib pkgs isNixOS mainUser inputs;
      config = effectiveConfig;
    };
  };
}
