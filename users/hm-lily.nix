{ osConfig, lib, pkgs, ... }:
let
  host = osConfig.networking.hostName;
  lowPower = host == "dweller";
  graphical = osConfig.services.xserver.enable;
in {
  home = {
    username = "lily";
    homeDirectory = "/home/lily";
    stateVersion = "23.11";
    sessionPath = [ ];
    sessionVariables = {
      MPD_HOST = "10.0.0.3";
      EDITOR = "kak";
    };
    shellAliases = { };
  };

  stylix = {
    autoEnable = graphical;
    image = if host == "snatcher" then
      pkgs.fetchurl {
          url = "https://w.wallhaven.cc/full/o5/wallhaven-o5ym69.jpg"; # BotW Link, Gerudo Town
          hash = "sha256-VDsfBM04iEdDjBnFBSXj7flyK/ydtrsa7cuQGC6GDrY=";
      }
    else if host == "minion" then
      pkgs.fetchurl {
          url = "https://archive.org/download/windows-xp-bliss-4k-lu-3840x2400/windows-xp-bliss-4k-lu-3840x2400.jpg"; # Windows XP "Bliss"
          hash = "sha256-QiSjrWx19YsHT425WTpa8NTptnBwGvdRm6/JRcSWAm8=";
      }
    else
      pkgs.fetchurl {
          url = "https://w.wallhaven.cc/full/yx/wallhaven-yxk7jg.jpg"; # BOTW Link/Zelda, modern day, subway
          hash = "sha256-HSRDhPk4HJj3ncfUYY/90hA1vAWcCnYVXOrFJF3aQ2k=";
      };
    fonts = rec {
      monospace = {
        name = "Maple Mono (NF)";
        package = pkgs.maple-mono-NF;
      };
      sansSerif = {
        name = "Cantarell";
        package = pkgs.cantarell-fonts;
      };
      serif = sansSerif;
    };
  };

  programs.atuin = {
      enable = true;
      settings = {
          sync_address = "http://10.0.0.3:8888";
          sync_frequency = "10m";
          auto_sync = true;
      };
  };
  programs.bat.enable = true;
  programs.btop.enable = true;
  programs.comodoro.enable = true;
  programs.eza = {
    enable = true;
    enableAliases = true;
    icons = true;
  };
  programs.feh.enable = graphical;
  programs.firefox = { enable = graphical; };
  programs.fzf.enable = true;
  programs.gallery-dl.enable = true;
  programs.gh.enable = true;
  programs.kakoune.enable = true;
  programs.khal.enable = true;
  programs.mangohud.enable = graphical && !lowPower;
  programs.mangohud.enableSessionWide = true;
  programs.mangohud.settings = {
    output_folder = /home/lily/Documents/mangohud;
    full = true;
  };
  programs.mpv = { enable = graphical; };
  programs.obs-studio = {
    enable = graphical && !lowPower;
    plugins = with pkgs.obs-studio-plugins; [
      obs-vkcapture
      input-overlay
      obs-text-pthread
      obs-source-clone
      obs-shaderfilter
      obs-source-record
      obs-pipewire-audio-capture
    ];
  };
  programs.pandoc.enable = true;
  programs.pywal.enable = true;
  programs.yt-dlp.enable = true;
  programs.zoxide.enable = true;
  programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      oh-my-zsh = {
          enable = true;
          theme = "darkblood";
          plugins = [ "vscode" ];
      };
  };

  programs.git = {
    enable = true;
    userName = "Lily Flavelle";
    userEmail = "me@neurario.com";
  };

  qt.enable = graphical;

  services.darkman = {
    enable = true;
    settings = {
      lat = 36.76;
      lng = 144.29;
      usegeoclue = true;
    };
    darkModeScripts = { };
    lightModeScripts = { };
  };

  services.playerctld.enable = true;

  wayland.windowManager.sway = {
      enable = lowPower;
      config = rec {
          modifier = "Mod4"; # Search/Logo on Chromebook
          terminal = "kitty";
      };
  };
}
