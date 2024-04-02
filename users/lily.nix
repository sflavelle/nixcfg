{ home-manager, config, pkgs, lib, inputs, ... }:

let

  host = config.networking.hostName;
  lowPower = host == "dweller";
  laptop = (host == "minion" || host == "dweller" || host == "badgeseller");
  hiDpi = (host == "badgeseller");
  graphical = config.services.xserver.enable;

  colors = config.home-manager.users.lily.stylix.base16Scheme;

  bizhawk = import inputs.bizhawk {
      forNixOS = true;
      pkgs = pkgs;
      mono = pkgs.mono;
      lua = pkgs.lua5_4;
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
          mimeo

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
          fractal
          
          playerctl
          pavucontrol
          rclone
          fontpreview
          astroid
          foliate
          spacedrive
          gnome.file-roller

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
            retroarchFull
            # bizhawk.emuhawk
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
        	hypridle swww hyprlock
        	grimblast
        	clipman wl-clipboard
        	gnome.nautilus blueman bluetuith
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

      services.gnome-keyring = {
          enable = true;
          components = [ "secrets" ];
      };

      gtk = {
          enable = true;
          iconTheme.package = pkgs.gnome.adwaita-icon-theme;
          iconTheme.name = "Adwaita";
      };

      stylix = {
        autoEnable = graphical;
        polarity = "dark";
        image = if host == "snatcher" then
          pkgs.fetchurl {
              url = "https://lemmy.ca/pictrs/image/4e94b9b8-a119-4b83-a617-3b1ba0413316.jpeg"; # In The Streets of Scandinavia, Kevin Gnutzmans, https://www.artstation.com/artwork/lRwQae
              hash = "sha256-y50sBdWG20l9g478wFgm4iE/DT9j9U6FXK1r0XdKWdE=";
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
        targets.waybar = {
            enableRightBackColors = true;
        };
      };

      programs.alacritty = {
          enable = true;
          settings = {
              window.blur = !lowPower;
              window.opacity = lib.mkForce 0.85;
              font.size = if hiDpi then lib.mkForce 18 else 12;
              colors.transparent_background_colors = true;
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
          style = ''
          	.modules-right {
              	font-size: 18px;
          	}
          '';
          settings = lib.mkMerge [
              ({ primarybar = { # Common settings
              			
                  "clock".format = "{:%A %d, %I:%M %p}";
                  "user".format = "{user}@${host}";

                  "cpu".format = "{}% ";
                  "memory".format = "{}% ";
                  "disk".format = "{percentage_used}% full 🖴";
                  "bluetooth" = {
											"tooltip-format" = "{controller_alias}\t{controller_address}";
											"tooltip-format-connected" = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
											"tooltip-format-enumerate-connected" = "{device_alias}\t{device_address}";
                  };

                  "pulseaudio" = {
                      "on-click" = "pavucontrol";
                      "format" = "{volume}% {icon}";
                      "format-bluetooth" = "{volume}% {icon}";
									    "format-muted" = "";
									    "format-icons" = {
								        "headphone" = "";
								        "hands-free" = "";
								        "headset" = "";
								        "phone" = "";
								        "portable" = "";
								        "car" = "";
								        "default" = ["" ""];
											};
                  };
			
									"network" = {
										"format-wifi" = "{essid} ({signalStrength}%) ";
										"format-ethernet" = "{ipaddr}/{cidr} 󰊗";
										"format-disconnected" = "no internet";
									};

                  "hyprland/window" = {
                      separate-outputs = true;
                      rewrite = {
                          "(.*) — Mozilla Firefox" = "🌎 $1";
                      };
                  };

                  "group/system" = {
                      orientation = "inherit";
                      modules = [ "cpu" "memory" "disk" "network"
                      	(lib.mkIf config.hardware.bluetooth.enable "bluetooth")
                      	(lib.mkIf laptop "backlight")
                      ];
                  };
              };
              })
              (lib.mkIf (host == "snatcher") {
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
          		})
          		
          		(lib.mkIf (host != "snatcher") {
              primarybar = {
                  layer = "top";
                  position = "top";
                  height = 32;
                  modules-left = [ "hyprland/workspaces" "mpris" ];
                  modules-center = [ "hyprland/window" ];
                  modules-right = [ "pulseaudio" "group/system" "tray" (lib.mkIf laptop "battery") "user" "clock" ];
              };
              })
          ];
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
      wayland.windowManager.hyprland = {
          enable = graphical;
          plugins = [
            # inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces # currently segfaults hyprland
          ];
          settings = {
              "$mod" = "SUPER";
              "$modShift" = "SUPERSHIFT";
              general = {
              	# allow_tearing = true;
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
                  enable_swallow = true;
                  swallow_regex = "^(Alacritty)$";
                  allow_session_lock_restore = true;
                  key_press_enables_dpms = true;
                  new_window_takes_over_fullscreen = 2;
              };
              env = [
                  "XDG_SESSION_TYPE,wayland"
                  "WLR_NO_HARDWARE_CURSORS,1"
                  "MOZ_ENABLE_WAYLAND,1"
                  "HYPRCURSOR_THEME,HyprBibataModernClassicSVG"
                  "HYPRCURSOR_SIZE,48"
              ];
              exec-once = [
#                "eww --restart open primarybar"
                "swaync"
                "hypridle"
                "udiskie &"
                "wl-paste -p -t text --watch clipman store -P --histpath='~/.local/share/clipman-primary.json'"
                "[workspace 1 silent] discord"
                "[workspace 3 silent] com.valvesoftware.Steam"
              ];
              exec = [
                  "swww init --no-cache; swww img ${config.home-manager.users.lily.stylix.image} --transition-type random --transition-step 10"
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
              	else if laptop then [
                  	"eDP-1,highrr,auto,1"
                  	",preferred,auto,1"
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
                  "3, monitor:DP-2, monitor:DP-4, on-created-empty:com.valvesoftware.Steam"
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
                  "float,class:^(org.mozilla.Thunderbird)$,title:^$"
                  "group new locked,class:^(steam)$"
                  "workspace 3 silent,class:^(steam)$"
                  "stayfocused,class:^(steam)$,title:^(Sign in to Steam)$"
                  "nofocus,class:^(steam)$,title:^(notificationtoasts)"
                  "rounding 0,class:^(steam)$,title:^(notificationtoasts)"
                  "tile,class:^(Archipelago)"
                  "tile,title:^(Lua Console)$"
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
									(app: lib.lists.forEach ["immediate" "tile" "workspace 3 silent" "idleinhibit focus" "group invade" ] (rule: rule + "," + app))
									));
          };
      };

      home.file = {
        ".config/Vencord/themes/stylix-discord.css".text = ''
/**
* @name base16
* @author ThePinkUnicorn
* @version 1.0.0
* @description base16 theme generated from https://github.com/tinted-theming/schemes
**/

:root {
    --base00: #''+colors.base00+''; /* Black */
    --base01: #''+colors.base01+''; /* Bright Black */
    --base02: #''+colors.base02+''; /* Grey */
    --base03: #''+colors.base03+''; /* Brighter Grey */
    --base04: #''+colors.base04+''; /* Bright Grey */
    --base05: #''+colors.base05+''; /* White */
    --base06: #''+colors.base06+''; /* Brighter White */
    --base07: #''+colors.base07+''; /* Bright White */
    --base08: #''+colors.base08+''; /* Red */
    --base09: #''+colors.base09+''; /* Orange */
    --base0A: #''+colors.base0A+''; /* Yellow */
    --base0B: #''+colors.base0B+''; /* Green */
    --base0C: #''+colors.base0C+''; /* Cyan */
    --base0D: #''+colors.base0D+''; /* Blue */
    --base0E: #''+colors.base0E+''; /* Purple */
    --base0F: #''+colors.base0F+''; /* Magenta */

    --primary-630: var(--base00); /* Autocomplete background */
    --primary-660: var(--base00); /* Search input background */
}

.theme-light, .theme-dark {
    --search-popout-option-fade: none; /* Disable fade for search popout */
    --bg-overlay-2: var(--base00); /* These 2 are needed for proper threads coloring */
    --home-background: var(--base00);
    --background-primary: var(--base00);
    --background-secondary: var(--base01);
    --background-secondary-alt: var(--base01);
    --channeltextarea-background: var(--base01);
    --background-tertiary: var(--base00);
    --background-accent: var(--base0E);
    --background-floating: var(--base01);
    --background-modifier-selected: var(--base00);
    --text-normal: var(--base05);
    --text-secondary: var(--base00);
    --text-muted: var(--base03);
    --text-link: var(--base0C);
    --interactive-normal: var(--base05);
    --interactive-hover: var(--base0C);
    --interactive-active: var(--base0A);
    --interactive-muted: var(--base03);
    --header-primary: var(--base06);
    --header-secondary: var(--base03);
    --scrollbar-thin-track: transparent;
    --scrollbar-auto-track: transparent;
}
'';
  };

      };

}
