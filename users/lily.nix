{ home-manager, config, pkgs, lib, inputs, ... }:

let

  host = config.networking.hostName;
  lowPower = host == "dweller";
  graphical = config.services.xserver.enable;

in {
  users.users.lily = {
    isNormalUser = true;
    description = "Lily Flavelle";
    extraGroups = [ "networkmanager" "wheel" "input" "audio" "video" ];
    shell = pkgs.zsh;
    packages = with pkgs;
      lib.mkMerge [
        ([ # All systems (terminal)
          neofetch
          emacs
          zellij
          calc
          edir
          epr

          just

          gallery-dl
          yt-dlp
          mpv
          playerctl
          mlt
          sox
          linuxwave

          nix-prefetch

          pandoc
        ])
        (lib.mkIf config.services.xserver.enable [ # All systems (graphical)
          # Programs
          vscode
          (discord.override {
            withOpenASAR = !lowPower;
            withVencord = !lowPower;
          })
          playerctl
          bitwarden
          rclone

        ])
        (lib.mkIf (config.services.xserver.enable && !lowPower) [ # More powerful devices
            libreoffice
            calibre
            protonup-qt
            steam-run
            jellyfin-media-player
        ])
        (lib.mkIf (config.services.xserver.enable && lowPower) [ # Less powerful, chromebooks etc)
            jellyfin-mpv-shim
        ])
        (lib.mkIf config.services.xserver.desktopManager.gnome.enable [ # Gnome-specific
          gnome.gnome-tweaks
          gnome.gnome-shell-extensions
        ])
      ];
  };

  nix.settings.trusted-users = [ "lily" ];
  security.sudo.wheelNeedsPassword = false;

  home-manager.users.lily = {
      home = {
        username = "lily";
        homeDirectory = "/home/lily";
        stateVersion = "23.11";
        sessionPath = [ ];
        sessionVariables = {
        };
        shellAliases = { };
        pointerCursor = {
            gtk.enable = true;
            name = "Vanilla-DMZ";
        };
      };

      gtk = {
          enable = true;
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
            name = "Monaspace Neon Var";
            package = pkgs.monaspace;
          };
          sansSerif = {
            name = "Cantarell";
            package = pkgs.cantarell-fonts;
          };
          serif = sansSerif;
        };
      };

      programs.alacritty = {
          enable = true;
          settings = {
              window.blur = true;
              window.opacity = lib.mkForce 0.75;
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
      programs.kakoune = {
          enable = true;
          defaultEditor = true;
          plugins = with pkgs.kakounePlugins; [ auto-pairs-kak kak-lsp smarttab-kak ];
          config = {
              tabStop = 2;
              ui = {
                  enableMouse = true;
              };
              wrapLines = {
                  enable = true;
                  indent = true;
                  maxWidth = 100;
                  word = true;
              };
          };
      };
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
              terminal = "foot";
          };
      };

      wayland.windowManager.hyprland = {
          enable = (config.networking.hostName == "snatcher");
          plugins = [
            # inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces # currently crashes on current hypr ver
          ];
          settings = {
              "$mod" = "SUPER";
              "$modShift" = "SUPERSHIFT";
              general.allow_tearing = true;
              decoration.blur = {
                  size = 20;
                  passes = 2;
                  
              };
              decoration.rounding = 12;
              dwindle = {
                pseudotile = true;
                preserve_split = true;
              };
              env = [
                  "LIBVA_DRIVER_NAME,nvidia"
                  "XDG_SESSION_TYPE,wayland"
                  "GBM_BACKEND,nvidia-drm"
                  "__GLX_VENDOR_LIBRARY_NAME,nvidia"
                  "WLR_NO_HARDWARE_CURSORS,1"
              ];
              exec-once = [
                "waybar"
                "dunst"
                "hyprctl hyprpaper preload '${config.home-manager.users.lily.stylix.image}'"
                "hyprctl hyprpaper wallpaper 'DP-1,${config.home-manager.users.lily.stylix.image}'"
                "hyprctl hyprpaper wallpaper 'DP-3,${config.home-manager.users.lily.stylix.image}'"
              ];
              monitor = [
                  "DP-2, preferred, 1440x900, 1"
                  "DP-1, preferred, 0x0, 1, transform, 3"
                  # Sometimes the monitors show up two IDs up. I have no idea why.
                  "DP-4, preferred, 1440x900, 1"
                  "DP-3, preferred, 0x0, 1, transform, 3"
              ];

              bindm = [
                  "$mod, mouse:272, movewindow"
                  "$mod, mouse:273, resizewindow"
              ];
              bind = [
                  # Quick Launches
                  "$mod, T, exec, alacritty"
                  "$mod, space, exec, wofi --show drun"

                  # Workspaces
                  "$mod, S, togglespecialworkspace,"
                  "$modShift, S, movetoworkspace, special"
                  "$mod, G, togglespecialworkspace, game"
                  "$modShift, G, movetoworkspace, special:game"
                  
                  "$mod, left, movefocus, l"
                  "$mod, right, movefocus, r"
                  "$mod, up, movefocus, u"
                  "$mod, down, movefocus, d"

                  "$modShift, left, movewindow, l"
                  "$modShift, right, movewindow, r"
                  "$modShift, up, movewindow, u"
                  "$modShift, down, movewindow, d"

                  # Window Management
                  "$mod, bracketleft, splitratio, -0.1"
                  "$mod, bracketright, splitratio, +0.1"
                  "$mod, backslash, togglesplit,"

                  "$mod, f, fullscreen, 0"
                  "$modShift, f, fakefullscreen,"
                  "$mod, period, togglefloating,"
                  "$modShift, period, pseudo,"

                  "$mod, q, killactive,"
              ] ++ (
                # This snippet copied from hyprland wiki
                builtins.concatLists (builtins.genList (
                  x: let
                    ws = let
                      c = (x+1) / 10;
                    in
                      builtins.toString (x + 1 - (c * 10));
                  in [
                      "$mod, ${ws}, workspace, ${toString (x + 1)}"
                      "$modShift, ${ws}, movetoworkspace, ${toString (x + 1)}"
                      ]
                    )
                    10)
                  );
              layerrule = [
                  "blur, waybar"
              ];
          };
      };
  };

}
