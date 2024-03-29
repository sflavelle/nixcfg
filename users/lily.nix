{ home-manager, config, pkgs, lib, inputs, ... }:

let

  host = config.networking.hostName;
  lowPower = host == "dweller";
  laptop = (host == "minion" || host == "dweller" || host == "badgeseller");
  graphical = config.services.xserver.enable;

  readerscript = pkgs.writeShellApplication {
      name = "ereadmenu";
      runtimeInputs = [ pkgs.wofi pkgs.fzf ];
      text = ''
      	book=$(find ~/eBooks -iname \*.epub | ${if graphical then ("${pkgs.wofi}/bin/wofi -i -w 2") else ("${pkgs.fzf}/bin/fzf -1 -0")})
      	${if graphical then "foliate" else "epr"} "$book"
      '';
  };

in {
  users.users.lily = {
    isNormalUser = true;
    description = "Lily Flavelle";
    extraGroups = [ "networkmanager" "wheel" "input" "audio" "video" ];
    hashedPasswordFile = config.sops.secrets."passwords/linux".path;
    shell = pkgs.zsh;
    packages = with pkgs;
      lib.mkMerge [
        ([ # All systems (terminal)
          neofetch
          zellij
          calc
          edir
          epr

          nom

          just

          mpv
          playerctl
          stc-cli
          musikcube

          nix-prefetch

          wayvnc

          pandoc
        ])
        (lib.mkIf config.services.xserver.enable [ # All systems (graphical)
          # Programs
          (discord.override {
            withOpenASAR = !lowPower;
            withVencord = !lowPower;
          })
          playerctl
          pavucontrol
          rclone
          fontpreview
          astroid
          foliate

          valent

          tetrio-desktop
          gweled rocksndiamonds
          torus-trooper

        ])
        (lib.mkIf (config.services.xserver.enable && !lowPower) [ # More powerful devices
            libreoffice
            calibre
            protonup-qt
            steam-run
            jellyfin-media-player
            vscode
            bitwarden
            mlt sox
        ])
        (lib.mkIf (config.services.xserver.enable && host == "snatcher") [
            gamehub gamescope
            ultimatestunts stuntrally xmoto
            runescape openttd
            zaz
        ])
        (lib.mkIf (config.services.xserver.enable && lowPower) [ # Less powerful, chromebooks etc)
            jellyfin-mpv-shim
            netsurf.browser
        ])
        (lib.mkIf config.services.xserver.desktopManager.gnome.enable [ # Gnome-specific
          gnome.gnome-tweaks
          gnome.gnome-shell-extensions
        ])
        (lib.mkIf config.home-manager.users.lily.wayland.windowManager.hyprland.enable [ # Hyprland utils
        	swaynotificationcenter wofi
        	hypridle hyprpaper hyprlock
        	grimblast
        	clipman wl-clipboard
        	gnome.nautilus
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
            "XDG_SCREENSHOTS_DIR" = "$HOME/Pictures/DesktopScreenshots";
        };
        shellAliases = { };
      };

      accounts = import ../fragments/lily-accounts.nix {inherit pkgs config lib home-manager inputs;};

      gtk = {
          enable = true;
          iconTheme.package = pkgs.gnome.adwaita-icon-theme;
          iconTheme.name = "Adwaita";
      };

      stylix = {
        autoEnable = graphical;
        image = if host == "snatcher" then
          pkgs.fetchurl {
              url = "https://w.wallhaven.cc/full/9d/wallhaven-9dzz7x.png"; # Celeste official art, Summit
              hash = "sha256-5F8ovJQOj6xVu5aiKufDtQH7J4ZJufXstphUhqsN9X4=";
          }
        else if host == "minion" then
          pkgs.fetchurl {
              url = "https://archive.org/download/windows-xp-bliss-4k-lu-3840x2400/windows-xp-bliss-4k-lu-3840x2400.jpg"; # Windows XP "Bliss"
              hash = "sha256-QiSjrWx19YsHT425WTpa8NTptnBwGvdRm6/JRcSWAm8=";
          }
        else if host == "badgeseller" then
        	pkgs.fetchurl {
            	url = "https://512pixels.net/downloads/macos-wallpapers-6k/10-4-6k.jpg"; # Mac OS X 10.4 'Tiger' wallpaper
            	hash = "sha256-YG/7pekoRwMma5ujN3ImYxdWt7GTxI06tXvdS1uTjP4=";
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
              window.blur = !lowPower;
              window.opacity = lib.mkForce 0.85;
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
      programs.eww = {
          enable = config.home-manager.users.lily.wayland.windowManager.hyprland.enable;
          configDir = ../fragments/eww;
      };
			programs.eza = {
        enable = true;
        icons = true;
      };
      programs.firefox = { enable = graphical; };
      programs.fzf.enable = true;
      programs.gallery-dl.enable = !lowPower;
      programs.gh.enable = true;
      programs.himalaya.enable = true;
      programs.imv.enable = graphical;
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
      programs.lf = {
          enable = true;
          settings = {
              mouse = true;
              icons = true;
          };
          previewer.source = pkgs.writeShellScript "pv.sh" ''
  					#!/bin/sh

					  case "$1" in
				      *.tar*) tar tf "$1";;
				      *.zip) unzip -l "$1";;
				      *.rar) unrar l "$1";;
				      *.7z) 7z l "$1";;
				      *.pdf) pdftotext "$1" -;;
				      *) highlight -O ansi "$1" || cat "$1";;
					  esac
						'';
      };
      programs.mangohud.enable = graphical && !lowPower;
      programs.mangohud.enableSessionWide = true;
      programs.mangohud.settings = {
        output_folder = /home/lily/Documents/mangohud;
        full = true;
      };
      programs.mpv = {
          enable = graphical;
          scripts = with pkgs.mpvScripts; [
              mpris
              autoload
              sponsorblock
              mpv-playlistmanager
              acompressor
              reload
          ];
      };
      programs.obs-studio = {
        enable = graphical && !lowPower;
        plugins = with pkgs.obs-studio-plugins; [
          obs-vkcapture
          input-overlay
          obs-text-pthread
          obs-shaderfilter
          obs-source-record
          obs-pipewire-audio-capture
          obs-teleport
        ];
      };
#      programs.notmuch.enable = true;
      programs.offlineimap.enable = true;
      programs.pandoc.enable = true;
      programs.yt-dlp.enable = true;
      programs.zsh = {
          enable = true;
          autosuggestion.enable = true;
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
        diff-so-fancy.enable = true;
        extraConfig = {
            credential.helper = "store";
        };
      };

      services.darkman = {
        enable = false;
        settings = {
          lat = 36.76;
          lng = 144.29;
          usegeoclue = true;
        };
        darkModeScripts = { };
        lightModeScripts = { };
      };

      services.playerctld.enable = true;
      programs.waybar = {
          enable = config.home-manager.users.lily.wayland.windowManager.hyprland.enable;
          package = pkgs.stable.waybar;
          systemd = { enable = true; target = "hyprland-session.target"; };
          settings = if (host == "snatcher") then {
              primarybar = {
                  layer = "top";
                  position = "top";
                  height = 32;
                  output = [
                      "DP-2"
                      "DP-4"
                  ];
                  
                  modules-left = [ "hyprland/workspaces" "mpris" ];
                  modules-center = [ "hyprland/window" ];
                  modules-right = [ "pulseaudio" "group/system" "tray" "user" "clock" ];

                  "hyprland/workspaces" = {
                  };
              };
              accessorybar = {
                  layer = "top";
                  position = "top";
                  height = 32;
                  output = [
                      "DP-1"
                      "DP-3"
                      "HDMI-A-2"
                  ];

                  modules-left = [ "hyprland/workspaces" ];
                  modules-center = [ "hyprland/window" ];
                  modules-right = [ "clock" ];
          		};
          	} else {
              primarybar = {
                  layer = "top";
                  position = "top";
                  height = 32;
                  modules-left = [ "hyprland/workspaces" "mpris" ];
                  modules-center = [ "hyprland/window" ];
                  modules-right = [ "pulseaudio" "group/system" "tray" "user" "clock" ];
              };
          };
      };

      xdg.desktopEntries = {
          readerscript = {
              name = "eReadMenu";
              genericName = "Book Launcher Picker";
              exec = "${readerscript}";
              terminal = false;
          };
      };

      xdg.configFile."hypr/idle-hass.sh" = {
          executable = true;
          text = ''
      	#!/bin/env bash
      	mqttx pub -t '/machines/$(cat /etc/hostname)/active)' -h 192.168.192.2 -p 1883 -m "$1"
      '';
      };

			xdg.configFile."hypr/hypridle.conf".text = ''
				general {
    				lock_cmd = pidof hyprlock || hyprlock
    				unlock_cmd = kill -USR1 $(pidof hyprlock)
    				before_sleep_cmd = loginctl lock-session
    				after_sleep_cmd = hyprctl dispatch dpms on
				}

#				listener {
#    				timeout = 300
#    				on-timeout = $HOME/.config/hypr/idle-hass.sh ON
#    				on-resume = $HOME/.config/hypr/idle-hass.sh OFF
#				}

				listener {
    				timeout = ${if laptop then "180" else "900"} # 15 minutes: lock session (Dweller: 3 minutes)
    				on-timeout = loginctl lock-session
				}

				listener {
    				timeout = ${if laptop then "300" else "1200"} # 20 minutes: monitors off (Dweller: 5 minutes)
    				on-timeout = hyprctl dispatch dpms off
    				on-resume = hyprctl dispatch dpms on
				}
			'';
			xdg.configFile."hypr/hyprlock.conf".text = ''
				general {
    				grace = 30
				}

				background {
    				monitor =
    				path = screenshot

    				blur_passes = 3
    				blur_size = 10
				}

				input-field {
				    monitor =
				    size = 200, 50
				    outline_thickness = 3
				    dots_size = 0.33 # Scale of input-field height, 0.2 - 0.8
				    dots_spacing = 0.15 # Scale of dots' absolute size, 0.0 - 1.0
				    dots_center = false
				    dots_rounding = -1 # -1 default circle, -2 follow input-field rounding
				    outer_color = rgb(151515)
				    inner_color = rgb(200, 200, 200)
				    font_color = rgb(10, 10, 10)
				    fade_on_empty = true
				    fade_timeout = 1000 # Milliseconds before fade_on_empty is triggered.
				    placeholder_text = <i>Input Password...</i> # Text rendered in the input box when it's empty.
				    hide_input = false
				    rounding = -1 # -1 means complete rounding (circle/oval)
				    check_color = rgb(204, 136, 34)
				    fail_color = rgb(204, 34, 34) # if authentication failed, changes outer_color and fail message color
				    fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i> # can be set to empty
				    fail_transition = 300 # transition time in ms between normal outer_color and fail_color
				    capslock_color = -1
				    numlock_color = -1
				    bothlock_color = -1 # when both locks are active. -1 means don't change outer color (same for above)
				    invert_numlock = false # change color if numlock is off

				    position = 0, -20
				    halign = center
				    valign = center
				}

				label {
    				monitor =
    				text = cmd[update:1000] echo "<span foreground='##ff2222'>$(date)</span>"
    				font_size = 24
    				font_family = "xkcd-Regular"
				}

			'';
			xdg.configFile."hypr/hyprpaper.conf".text = ''
				splash = false
			  
				preload = ${config.home-manager.users.lily.stylix.image}
				wallpaper = ,${config.home-manager.users.lily.stylix.image}
				'';
      wayland.windowManager.hyprland = {
          enable = graphical;
          plugins = [
            # inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces # currently segfaults hyprland
          ];
          settings = {
              "$mod" = "SUPER";
              "$modShift" = "SUPERSHIFT";
              general = {
              	allow_tearing = true;
								gaps_out = if (host == "dweller") then 5 else 20;
								cursor_inactive_timeout = 20;
							};
              decoration.blur = if lowPower then { enabled = false;} else {
                  size = 20;
                  passes = 2;
                  
              };
              decoration.drop_shadow = !lowPower;
              decoration.rounding = 12;
              input = {
                  touchpad = {
                      natural_scroll = true;
                      clickfinger_behavior = true;
                  };
              };
              dwindle = {
                pseudotile = true;
                preserve_split = true;
              };
              misc = {
                  disable_hyprland_logo = true;
                  disable_splash_rendering = true;
              };
              env = [
                  "LIBVA_DRIVER_NAME,nvidia"
                  "XDG_SESSION_TYPE,wayland"
                  "GBM_BACKEND,nvidia-drm"
                  "__GLX_VENDOR_LIBRARY_NAME,nvidia"
                  "WLR_NO_HARDWARE_CURSORS,1"
                  "MOZ_ENABLE_WAYLAND,1"
                  "HYPRCURSOR_THEME,HyprBibataModernClassicSVG"
                  "HYPRCURSOR_SIZE,48"
              ];
              exec-once = [
#                "eww --restart open primarybar"
                "swaync"
                "hyprpaper"
                "hypridle"
                "udiskie &"
                "wl-paste -p -t text --watch clipman store -P --histpath='~/.local/share/clipman-primary.json'"
              ];
              monitor =
              	if host == "snatcher" then [
                  "DP-2, preferred, 1440x900, 1"
                  "DP-1, preferred, 0x0, 1, transform, 3"
                  # Sometimes the monitors show up two IDs up. I have no idea why.
                  "DP-4, preferred, 1440x900, 1"
                  "DP-3, preferred, 0x0, 1, transform, 3"
                  # Then my spare
                  "HDMI-A-2, 1920x1080@120, 5280x1440, 1"
              		]
              	else ", preferred, auto, 1";

              bindm = [
                  "$mod, mouse:272, movewindow"
                  "$mod, mouse:273, resizewindow"
              ];
              bindl = [
                  ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
                  ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
              ];
              bind = [
                  # Quick Launches
                  "$mod, T, exec, alacritty"
                  "$mod, E, exec, nautilus"
                  "$mod, B, exec, firefox"
                  "$mod, space, exec, wofi -i -w 4 --show drun"
                  "$mod, backspace, exec, swaync-client -t"
                  "$mod, V, exec, clipman pick -t wofi"

                  ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

                  "$mod, escape, exec, sleep 1 && hyprctl dispatch dpms off"

                  # Workspaces
                  "$mod, S, togglespecialworkspace,"
                  "$modShift, S,movetoworkspace, special"
                  "$mod, G, togglespecialworkspace, game"
                  "$modShift, G,movetoworkspace, special:game"
                  
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
                  "$mod, slash, pin,"

                  "$mod, C, centerwindow,"
                  "$mod, M, fullscreen, 1" #Maximise

                  "$mod, q, killactive,"
                  "$mod alt, q, exit,"

                  # Group Management
                  "$mod ALT, G, togglegroup,"
                  "$mod, TAB, changegroupactive,f"
                  "$modShift, TAB, changegroupactive,b"
                  "$mod ALT,left, movewindoworgroup,l"
                  "$mod ALT,right, movewindoworgroup,r"
                  "$mod ALT,up, movewindoworgroup,u"
                  "$mod ALT,down, movewindoworgroup,d"

                  # Screenshots
                  ", print, exec, grimblast --notify copysave screen" # Full desktop screenshot
                  "SHIFT, print, exec, grimblast --freeze --notify copysave area" # Area/Window Capture
                  "ALT, print, exec, grimblast --notify copysave active" # Active Window Capture
                  "CTRL, print, exec, grimblast --notify copysave output" # Active Monitor
              ] ++ (
                # This snippet copied from hyprland wiki
                builtins.concatLists (builtins.genList (
                  x: let
                    ws = let
                      c = (x+1) / 10;
                    in
                      builtins.toString (x + 1 - (c * 10));
                  in [
                      "$mod, ${ws},workspace, ${toString (x + 1)}"
                      "$modShift, ${ws},movetoworkspace, ${toString (x + 1)}"
                      ]
                    )
                    10)
                  );
              layerrule = [
                  "blur, waybar"
              ];
              workspace = if host == "snatcher" then [
                  "1, monitor:DP-1, monitor:DP-3, default:true, gapsout:5, persistent:true"
                  "2, monitor:DP-2, monitor:DP-4, default:true, persistent:true"
                  "3, monitor:DP-2, monitor:DP-4, on-created-empty:steam"
                  "4, monitor:DP-2, monitor:DP-4"
                  "5, monitor:DP-1, monitor:DP-3, gapsout:5"
              ] else [];
              windowrule = [
                  "float, confirm"
                  "float, dialog"
                  "float, download"
                  "float, notification"
                  "float, error"
                  "float, splash"
                  "float, title:Open File"
                  "float, title:^(Picture-in-Picture)$"
              ];
              windowrulev2 = [
                  "float,class:^(poptracker)$,title:^(Settings)"
                  "float,class:^(com.usebottles.bottles)$,title:^(Bottles)$"
                  "group new,class:^(steam)$"
                  "workspace 3 silent,class:^(steam)$"
                  "stayfocused,class:^(steam)$,title:^(Sign in to Steam)$"
                  "tile,class:^(Archipelago.+Client)$"
                  "monitor 0,class:mpv"
                  "suppressevent fullscreen maximize,class:mpv"
                  "opacity 0 override,title:^(Wine System Tray)$"
                  "nofocus,title:^(Wine System Tray)$"
              ] ++
              (lib.lists.forEach [
                  "opacity 0.0 override 0.0 override"
                  "noanim"
                  "noinitialfocus"
                  "maxsize 1 1"
                  "noblur"
              ] (rule: rule + ", class:^(xwaylandvideobridge)$"))
              ++
              (lib.lists.flatten (lib.lists.forEach [
                  "class:Celeste"
                  "class:(steam_app_)"
                  "title:(Nix|Emu|Biz)Hawk"
                  "class:^(rocksndiamonds)$"
                  ]
									(app: lib.lists.forEach ["immediate" "tile" "workspace 3 silent" "monitor 1" "idleinhibit focus" "group set" "suppressevent fullscreen maximize" "fullscreen" ] (rule: rule + "," + app))
									));
          };
      };
  };

}
