{ config, lib, pkgs, mainUser, inputs, nixgl ? null, ... }:
let
  isNixOS = config ? hostSpec;
  user = if !isNixOS then "lily" else mainUser;

  nixGLConfig = if nixgl != null && !isNixOS then {
    packages = import nixgl { inherit pkgs; };
    defaultWrapper = "mesa"; # or the driver you need
    installScripts = [ "mesa" ];
  } else {};

  # defaultConfig = {
  #   hostSpec = {
  #     hostName = "noHost";
  #     isServer = false;
  #     isMinimal = false;
  #     isHandheld = false;
  #   };
  #   lib = lib;
  # };

  # effectiveConfig = if isNixOS then config else lib.mkMerge [ defaultConfig config ];
  effectiveConfig = config;

  webapp-browser = "${pkgs.ungoogled-chromium}/bin/chromium";
in
{
  nixGL = nixGLConfig;

  home = {
    username = if !isNixOS then "lily" else user;
    homeDirectory = "/home/${user}";
    shell.enableShellIntegration = true;
    stateVersion = "25.05";
    packages = with pkgs; lib.mkMerge [
      [ # All systems
        mpc
        fuzzel
        pipe-viewer
        mosh
      ]
      (lib.mkIf (!config.hostSpec.isServer && config.hostSpec.hasPhysicalKeyboard) [
        ghostty
      ])
      (lib.mkIf (!config.hostSpec.isServer) [
        xwayland-satellite
        jellyfin-media-player
        obsidian
        webcord-vencord
      ])
    ];
  };

  xdg.enable = true;

  # Some quick webapp shortcuts
  xdg.desktopEntries.tgc = {
    name = "The General Chat";
    exec = "${webapp-browser} --app=https://thegeneral.chat";
  };
  xdg.desktopEntries.bsky = {
    name = "BlueSky";
    exec = "${webapp-browser} --app=https://bsky.app";
  };

  programs.eza.enable = true;
  programs.home-manager.enable = true;
  programs.yazi.enable = true;

  # Configs
  programs.mpv = {
    enable = true;
    package = if nixGLConfig != null && effectiveConfig.lib ? nixGL then effectiveConfig.lib.nixGL.wrap pkgs.mpv else pkgs.mpv;
    scripts = with pkgs.mpvScripts; [
      sponsorblock acompressor mpris
    ];
    config = {
      fs = true;
      osd-playing-msg="Now Playing: \${media-title}";
      ytdl-format = if config.hostSpec.isMinimal then
        "bestvideo[height<=?720]+bestaudio/best"
        else "bestvideo[height<=?1440][fps<=?30]+bestaudio/best";
      ytdl-raw-options = [
        "cookies-from-browser=firefox"
        "mark-watched="
        "match-filter=original_url!*=/shorts & url!*=/shorts/"
      ];
    };
  };
  programs.rclone = {
    enable = true;
  };
  programs.zoxide = {
    enable = true;
#     options = ["--cmd cd"];
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
  # programs.niri = {
  #   enable = isNixOS && !effectiveConfig.hostSpec.isServer;
  #   package = pkgs.niri-unstable;
  #   settings = import ./cfg/niri.nix {
  #     inherit lib pkgs isNixOS mainUser inputs;
  #     config = effectiveConfig;
  #   };
  # };
}
