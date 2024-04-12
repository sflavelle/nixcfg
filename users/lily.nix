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
          rbw

          nix-prefetch

          wayvnc

          pandoc

          cl-wordle bastet _2048-in-terminal
          
          
        ])
        (lib.mkIf config.services.xserver.enable [ # All systems (graphical)
          # Programs
          (discord.override {
            withOpenASAR = true;
            withVencord = true;
          })
          
          playerctl
          pavucontrol
          fontpreview
          astroid
          goldwarden

          youtube-tui

          virt-viewer

        ])
        (lib.mkIf (config.services.xserver.enable && !lowPower) [ # More powerful devices
            libreoffice
            calibre
            protonup-qt
            steam-run
            jellyfin-media-player
            vscode
            mlt sox
            retroarchFull
            tetrio-desktop
            # bizhawk.emuhawk
        ])
        (lib.mkIf (config.services.xserver.enable && host == "snatcher") [
            appflowy

            gamehub gamescope
            ultimatestunts stuntrally xmoto
            runescape openttd
            zaz
        ])
        (lib.mkIf (config.services.xserver.enable && lowPower) [ # Less powerful, chromebooks etc)
            jellyfin-mpv-shim
        ])
        (lib.mkIf config.services.xserver.desktopManager.gnome.enable [ # Gnome-specific
          gnome.gnome-tweaks
          gnome.gnome-shell-extensions
        ])
        (lib.mkIf config.home-manager.users.lily.wayland.windowManager.sway.enable [ # Hyprland utils
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
              font.size = 12;
              colors.transparent_background_colors = true;
          };
      };
      programs.bat.enable = true;
      programs.btop.enable = true;
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
          config = {
              keep-open = "yes";
              ytdl-format = "ytdl-format=bestvideo[height<=?1080][fps<=?30]+bestaudio/best";
              ytdl-raw-options = "cookies-from-browser=firefox";
          };
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
      programs.waybar = {
          enable = config.home-manager.users.lily.wayland.windowManager.sway.enable;
          package = pkgs.stable.waybar;
          systemd = { enable = true; target = "sway-session.target"; };
          style = ''
          	.modules-right {
              	font-size: 18px;
          	}
          '';
          settings = lib.mkMerge [
              ({ primarybar = { # Common settings
              			
                  "clock".format = "{:%A %d\n%I:%M %p}";
                  "user".format = "{user}@${host}";

                  "cpu".format = "{load} ";
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

                  "backlight" = {
                      "format" = "{percent}% {icon}";
                      "format-icons" = ["" ""];
                      "on-scroll-up" = "${pkgs.brillo}/bin/brillo -A 5";
                      "on-scroll-down" = "${pkgs.brillo}/bin/brillo -U 5";
                  };
			
									"network" = {
										"format-wifi" = "{essid} ({signalStrength}%) ";
										"format-ethernet" = "{ipaddr}/{cidr} 󰊗";
										"format-disconnected" = "no internet";
									};

                  "sway/window" = {
                      separate-outputs = true;
                      rewrite = {
                          "(.*) — Mozilla Firefox" = "🌎 $1";
                      };
                  };

                  "group/system" = {
                      orientation = "orthogonal";
                      modules = [ "cpu" "memory"
                      ];
                  };

                  "group/network" = {
                      orientation = "orthogonal";
                      modules = ["network"
                      	(lib.mkIf config.hardware.bluetooth.enable "bluetooth")
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
                      "DP-1"
                      "DP-3"
                  ];
                  
                  modules-left = [ "sway/workspaces" "mpris" ];
                  modules-center = [ "sway/window" ];
                  modules-right = [ "pulseaudio" "disk" "group/system" "group/network" "tray" "user" "clock" ];
              };
              accessorybar = {
                  layer = "top";
                  position = "top";
                  height = 32;
                  output = [
                      "DP-2"
                      "DP-4"
                      "HDMI-A-2"
                  ];

                  modules-left = [ "sway/workspaces" ];
                  modules-center = [ "sway/window" ];
                  modules-right = [ "clock" ];
          		};
          		})
          		
          		(lib.mkIf (host != "snatcher") {
              primarybar = {
                  layer = "top";
                  position = "top";
                  height = 32;
                  modules-left = [ "sway/workspaces" "mpris" ];
                  modules-center = [ "sway/window" ];
                  modules-right = [
                      "pulseaudio" "group/system" "group/network"
                      (lib.mkIf laptop "battery")
                      	(lib.mkIf laptop "backlight")
                      "tray" "user" "clock" ];
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

      wayland.windowManager.hyprland = {
          enable = false;
          plugins = [
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
                "[workspace 11 silent] discord"
                "[workspace 3 silent] com.valvesoftware.Steam"
              ];
              exec = [
                  "swww init --no-cache; swww img ${config.home-manager.users.lily.stylix.image} --transition-type random --transition-step 10"
              ];
              monitor =
              	if host == "snatcher" then [
                  "DP-1, preferred, 1440x900, 1"
                  "DP-2, preferred, 0x0, 1, transform, 3"
                  # Sometimes the monitors show up two IDs up. I have no idea why.
                  "DP-3, preferred, 1440x900, 1"
                  "DP-4, preferred, 0x0, 1, transform, 3"
                  # Then my spare
                  "HDMI-A-2, 1920x1080@60, 5280x1440, 1"
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
                  ", XF86MonBrightnessDown, exec, brillo -U 5"
                  ", XF86MonBrightnessUp, exec, brillo -A 5"
              ];
              bind = [
                  # Quick Launches
                  "$mod, T, exec, alacritty"
                  "$mod, E, exec, nautilus"
                  "$mod, B, exec, firefox"
                  "$mod, V, exec, pavucontrol"
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
                  "monitor HDMI-A-2,class:mpv"
                  "suppressevent fullscreen maximize,class:mpv"
                  "opacity 0 override,title:^(Wine System Tray)$"
                  "nofocus,title:^(Wine System Tray)$"
                  "group new,class:^(steam_app_),title:^(Z:\\home\\lily\\)"
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

      wayland.windowManager.sway = {
        enable = true;
        systemd.xdgAutostart = true;
        config = rec {
          terminal = "alacritty";
          modifier = "Mod4";

					gaps = {
    					smartBorders = "on";
    					smartGaps = true;
					};
          
          keybindings = 
          let 
            modifier = config.home-manager.users.lily.wayland.windowManager.sway.config.modifier;
            modShift = "${modifier}+Shift";
          in lib.mkOptionDefault {
              "${modifier}+t" = "exec alacritty"; # Terminal
              "${modifier}+e" = "exec nautilus"; # Explorer
              "${modifier}+b" = "exec firefox"; # Browser
              "${modifier}+a" = "exec pavucontrol"; # Audio
              "${modifier}+space" = "exec wofi -i -w 4 --show drun";
              "${modifier}+backspace" = "exec swaync-client -t";


              "XF86AudioRaiseVolume" = "exec wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+";
              "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
              "XF86MonBrightnessDown" = "exec brillo -U 5";
              "XF86MonBrightnessUp" = "exec brillo -A 5";

              "${modifier}+1" = "exec swaysome focus 1";
              "${modifier}+2" = "exec swaysome focus 2";
              "${modifier}+3" = "exec swaysome focus 3";
              "${modifier}+4" = "exec swaysome focus 4";
              "${modifier}+5" = "exec swaysome focus 5";
              "${modifier}+6" = "exec swaysome focus 6";
              "${modifier}+7" = "exec swaysome focus 7";
              "${modifier}+8" = "exec swaysome focus 8";
              "${modifier}+9" = "exec swaysome focus 9";
              "${modifier}+0" = "exec swaysome focus 10";
              
              "${modShift}+1" = "exec swaysome move 1";
              "${modShift}+2" = "exec swaysome move 2";
              "${modShift}+3" = "exec swaysome move 3";
              "${modShift}+4" = "exec swaysome move 4";
              "${modShift}+5" = "exec swaysome move 5";
              "${modShift}+6" = "exec swaysome move 6";
              "${modShift}+7" = "exec swaysome move 7";
              "${modShift}+8" = "exec swaysome move 8";
              "${modShift}+9" = "exec swaysome move 9";
              "${modShift}+0" = "exec swaysome move 10";
              
              "${modShift}+backslash" = "splitv";
              "${modShift}+minus" = "splith";
              "${modifier}+f" = "fullscreen toggle";
              "${modifier}+slash" = "layout toggle splitv splith stacking tabbed";

              "${modifier}+q" = "kill";
              "${modShift}+q" = "exec swaymsg exit"; # Need to setup nag
            };
          startup = [
            { command = "swaync"; }
            { command = "swayidle"; }
            { command = "udiskie &"; }
            { command = "swayosd-server"; }
            { command = "wl-paste -p -t text --watch clipman store -P --histpath='~/.local/share/clipman-primary.json'"; }
            { command = "swaysome init 1"; }
            { command = "swaysome rearrange-workspaces"; always = true; }
            { command = "swaymsg focus output DP-1"; }
          ];

          output =
          if host == "snatcher" then {
              DP-1 = {
                  mode = "3840x2160";
                  position = "1440 900";
              };
              DP-2 = {
                  mode = "3440x1440";
                  position = "0 0";
                  transform = "90";
              };
              HDMI-A-2 = {
                  mode = "1920x1080";
                  position = "5280 1440";
              };
          }  else {};
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
