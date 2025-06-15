{ config, lib, pkgs, mainUser, name, inputs, outputs ? null, nixgl ? null, ... }:
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
  #     hostName = "noHst";
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
        yt-dlp
        uair
        musikcube
        clipboard-jh
      ]
      (lib.mkIf (!config.hostSpec.isServer && config.hostSpec.hasPhysicalKeyboard) [
        alacritty
      ])
      (lib.mkIf (!config.hostSpec.isServer) [
        xwayland-satellite
        jellyfin-media-player
        outputs.packages.${system}.vacuumtube
        obsidian
        webcord-vencord

        floorp

        quodlibet

        # WM Utilities
        inputs.ignis.packages.${system}.ignis

        # Fonts
        glasstty-ttf ultimate-oldschool-pc-font-pack nerd-fonts.ubuntu-sans ubuntu-sans-mono
        minecraftia monocraft pixel-code nerd-fonts.monaspace mona-sans hubot-sans aileron
        dinish comic-relief tt2020 nerd-fonts.jetbrains-mono nerd-fonts.im-writing
        nerd-fonts.symbols-only
      ])
    ];
  };

  accounts = import ./accounts.nix {
      inherit lib pkgs inputs;
      config = effectiveConfig;
    };

  xdg.enable = true;
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config.common = {
      default = ["gtk"];
      "org.freedesktop.portal.ScreenCast" = ["gnome"];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      gnome-keyring
      # xdg-desktop-portal-wlr
    ];
  };

  # Some quick webapp shortcuts
  xdg.desktopEntries.tgc = {
    name = "The General Chat";
    exec = "${webapp-browser} --app=https://thegeneral.chat";
    categories = [ "Network" "Feed" ];
  };
  xdg.desktopEntries.bsky = {
    name = "BlueSky";
    exec = "${webapp-browser} --app=https://bsky.app";
    categories = [ "Network" "Feed" ];
  };

  # Fonts
  fonts.fontconfig.enable = true;

  programs.eza.enable = true;
  programs.home-manager.enable = true;
  programs.yazi.enable = true;

  # Configs
  programs.git = {
    enable = true;
    lfs.enable = true;
    userEmail = "me@neurario.com";
    userName = name;
  };
  programs.helix = {
    enable = true;
    defaultEditor = true;
  };
  programs.himalaya = {
    enable = true;
    settings = {
      downloads-dir = "/home/${user}/Downloads/Mail";
    };
  };
  programs.hyfetch = {
    enable = true;
    settings = {
      preset = "genderfluid";
      mode = "rgb";
      brightness = "50%";
      color_align.mode = "horizontal";
    };
  };
  programs.mpv = {
    enable = true;
    package = if nixGLConfig != null && effectiveConfig.lib ? nixGL then effectiveConfig.lib.nixGL.wrap pkgs.mpv else pkgs.mpv;
    scripts = with pkgs.mpvScripts; [
      sponsorblock acompressor mpris
    ];
    defaultProfiles = if config.hostSpec.isMinimal then
      [ "fast" ]
      else [ "gpu-hq" ];
    config = {
      fs = true;
      osd-playing-msg="Now Playing: \${media-title}";
      ytdl-format = if config.hostSpec.isMinimal then
        "bestvideo[height<=?480][fps<=?30]+bestaudio/best"
        else "bestvideo[height<=?1440][fps<=?30]+bestaudio/best";
      ytdl-raw-options = [
        (lib.mkIf config.programs.firefox.enable "cookies-from-browser=firefox")
        "mark-watched="
        "match-filter=original_url!*=/shorts & url!*=/shorts/"
      ];
    };
  };
  programs.rbw = {
    enable = true;
    settings = {
      base_url = "https://vault.thegeneral.chat";
      email = "me@neurario.com";
      pinentry = pkgs.pinentry-qt;
    };
  };
  programs.rclone = {
    enable = true;
    remotes = {

    };
  };
  programs.rofi = {
    enable = true;
    terminal = "${pkgs.ghostty}/bin/ghostty";
    package = pkgs.rofi-wayland;
    modes = [
      "drun" "ssh" "window"
    ];
  };
  programs.thunderbird = {
    enable = !config.hostSpec.isServer;
    profiles = {
      "main".isDefault = true;
    };
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

  services.swww = {
    enable = !config.hostSpec.isServer;
  };

  # Environments
  programs.niri = {
    # enable = isNixOS && !effectiveConfig.hostSpec.isServer;
    # package = pkgs.niri-unstable;
    settings = import ./cfg/niri.nix {
      inherit lib pkgs isNixOS mainUser inputs;
      config = effectiveConfig;
    };
  };
}
