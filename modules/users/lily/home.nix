{ config, lib, system ? "x86_64-linux", pkgs, mainUser, name, inputs, outputs ? null, nixgl ? null, ... }:
let
  isNixOS = config ? hostSpec;
  user = if !isNixOS then "lily" else mainUser;
  flakePackages = outputs.packages.${system};

  primaryMonitor = lib.head (lib.filter (m: m.primary) config.monitors);

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
        mpc epy
        pipe-viewer
        mosh
        yt-dlp
        uair
        musikcube
        cliphist wl-clipboard-rs
        brightnessctl
        termdown

        inputs.agenix.packages.${system}.default

        gnumake

        (python3.withPackages (ps: with ps; 
        [
          pelican
        ] 
        ++ pelican.optional-dependencies.markdown))
      ]
      (lib.mkIf (!config.hostSpec.isServer) [
        xwayland-satellite
        jellyfin-media-player
        flakePackages.vacuumtube
        obsidian
        webcord-vencord caprine overlayed
        zathura bemenu file-roller feh
        libreoffice-qt6-fresh

        nautilus

        floorp

        quodlibet

        toot

        # Fonts
        flakePackages.otf-determination flakePackages.ttf-utpapyrus flakePackages.ttf-utsans

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
      default = ["gnome" "gtk"];
      "org.freedesktop.portal.ScreenCast" = ["gnome"];
      "org.freedesktop.portal.FileChooser" = [ "gnome" ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      gnome-keyring
      # xdg-desktop-portal-wlr
    ];
  };

  stylix.targets = lib.mkIf config.hostSpec.isAutoStyled {
    waybar.addCss = false;
    vencord.enable = true; # I'm using Webcord but it has vencord support so w/e
    vscode.enable = true; 
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

  systemd.user.services.wallpaper-apply = lib.mkIf (config.hostSpec.wallpaper != null) {
    Unit = {
      Description = "Apply wallpaper using swww";
      After = [ "swww.service" ];
      Wants = [ "swww.service" ];
    };
    Service.ExecStart = "${pkgs.swww}/bin/swww img ${config.hostSpec.wallpaper}";
    Service.Type = "oneshot";
  };

  # Fonts
  fonts.fontconfig.enable = true;

  programs.eza.enable = true;
  programs.home-manager.enable = true;
  programs.vscode = {
    enable = !config.hostSpec.isServer;
    package = pkgs.vscode-fhs;
    profiles.default.userSettings = {
      "workbench.colorTheme" = "Stylix";
      "workbench.iconTheme" = "vscode-icons";
      "editor.lineHeight" = 20;
      "editor.tabSize" = 2;
      "editor.wordWrap" = "on";
      "terminal.integrated.fontFamily" = "Determination Mono, monospace";
      "update.channel" = "none"; # Disable updates
      "[nix]"."editor.tabSize" = 2;
      "git.confirmSync" = false;
    };
  };
  programs.yazi.enable = true;

  # Configs
  programs.fish = {
    enable = true;
    functions = {
      mper = "himalaya $argv --account personal";
      mpro = "himalaya $argv --account professional";
      beet-dlp = ''
        mkdir -p /tmp/beetdlp-$(id -u)
        pushd /tmp/beetdlp-$(id -u)
        ${pkgs.yt-dlp}/bin/yt-dlp -t mp3 --embed-metadata -o "%(extractor)s/%(album_artist)s - %(album)s/%(playlist_index)02d - %(title)s.%(ext)s" $argv
        beet import .
        popd
      '';
    };
  };
  programs.git = {
    enable = true;
    lfs.enable = true;
    userEmail = "me@neurario.com";
    userName = name;
  };
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings.editor = {
      "soft-wrap"."enable" = true;
    };
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
  programs.thunderbird = {
    enable = !config.hostSpec.isServer;
    profiles = {
      "main".isDefault = true;
    };
  };

  programs.wezterm = {
    enable = (!config.hostSpec.isServer && config.hostSpec.hasPhysicalKeyboard);
    extraConfig = ''
      return {
        font_size = 10.0,
        font = wezterm.font_with_fallback {
          'Determination Mono',
        },
        hide_tab_bar_if_only_one_tab = true,
      }
    '';
  };

  programs.zellij = {
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

  services.swww = {
    enable = !config.hostSpec.isServer;
  };

  programs.waybar = {
    enable = !config.hostSpec.isServer;
    systemd.enable = true;
    systemd.target = "graphical-session.target";
    settings = import ./cfg/waybar.nix {
      inherit config lib pkgs inputs mainUser isNixOS;
    };
    style = import ./cfg/waybar-css.nix {
      inherit config lib inputs mainUser isNixOS;
    };
  };

  services.fnott = {
    enable = !config.hostSpec.isServer;
    settings = {
      main.output = lib.mkIf (config.monitors != []) primaryMonitor.name;
    }; 
  };

  services.swayidle = {
    enable = !config.hostSpec.isServer;
    timeouts = [
      
    ];
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
