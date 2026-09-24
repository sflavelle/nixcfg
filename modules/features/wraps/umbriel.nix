{ self, inputs, ... }:
{
  # Umbriel — Wayland compositor on wlroots + umbrielfx (hard fork of SceneFX)
  # Docs: https://docs.noctalia.dev/umbriel/
  # Config reference: https://docs.noctalia.dev/umbriel/configuration/
  # Example: https://github.com/noctalia-dev/umbriel/blob/main/examples/config.toml
  #
  # Usage: add `self.nixosModules.umbriel` to `imports` in
  # `modules/hosts/my-machine/configuration.nix` next to `self.nixosModules.niri`.
  # Then pick Umbriel vs Niri on the greeter (F3). `session.default = "niri"` in
  # noctalia-greeter will keep Niri default until you change it.
  #
  # Mirrors `niri.nix` structure where possible, but Umbriel uses TOML via
  # `programs.umbriel.settings` (Home Manager) instead of wrapper-modules.
  # See also: nix/home-module.nix (settings -> $XDG_CONFIG_HOME/umbriel/config.toml)
  # and nix/nixos-module.nix (system package + portal + sessionPackages).

  flake.nixosModules.umbriel =
    {
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        inputs.umbriel.nixosModules.default
      ];

      # System: install Umbriel + portal + session .desktop
      # https://raw.githubusercontent.com/noctalia-dev/umbriel/main/nix/nixos-module.nix
      # withDefaultPackage (via inputs.umbriel.nixosModules.default) already sets
      # package = inputs.umbriel.packages.<system>.default as mkDefault, so just enable:
      programs.umbriel.enable = true;
      # Keep portal for screen sharing (OBS, browsers). Set to null to disable:
      # programs.umbriel.portalPackage = null;

      # User: declarative TOML config (live-reloaded, validated at build)
      # https://docs.noctalia.dev/umbriel/configuration/
      # https://github.com/noctalia-dev/umbriel/blob/main/examples/config.toml

      programs.noctalia = {
        enable = true;
        systemd.enable = true;
        systemd.target = "umbriel-session.target";
        recommendedServices.enable = true;
      };

      home-manager.users.lily = {
        imports = [ inputs.umbriel.homeModules.default ];

        programs.umbriel = {
          enable = true;

          settings = {
            # Include Noctalia's generated palette — https://docs.noctalia.dev/umbriel/configuration/#include
            # Noctalia writes ~/.config/umbriel/noctalia.toml; this makes Umbriel load it (main file still wins)
            include = {
              files = [ "noctalia.toml" ];
              optional.files = [ "outputs.toml" ];
            };

            # General — https://docs.noctalia.dev/umbriel/configuration/#general
            general = {
              autostart = [
                # (lib.getExe pkgs.noctalia)
                (lib.getExe pkgs.discord)
                (lib.getExe pkgs.telegram-desktop)
              ];
              mod_key = "Super"; # Mod in keybinds; Alt when nested (same as niri cursor mod)
              xwayland = true; # needs xwayland-satellite on PATH (niri uses satellite too)
              show_cheatsheet = true;
              focus_on_activate = false;
            };

            # Workspaces — https://docs.noctalia.dev/umbriel/workspaces/
            workspaces = {
              back_and_forth = false;
              empty_above = false;
            };

            # Per-workspace layout overrides — https://docs.noctalia.dev/umbriel/workspaces/#workspace-rules
            # https://github.com/noctalia-dev/umbriel/blob/main/examples/config.toml#L118
            # Third workspace uses dwindle, others stay scrolling (global layout.mode)
            # workspace = [
            #   {
            #     name = "2";
            #     layout.mode = "master";
            #   }
            #   {
            #     name = "3";
            #     layout.mode = "dwindle";
            #   }
            # ];

            # Layout — https://docs.noctalia.dev/umbriel/layout/
            # Mirrors niri: gaps 5, scrolling default (niri is scrolling-only)
            layout = {
              mode = "scrolling"; # scrolling | dwindle | master — per-workspace override via [[workspace]]
              gap = 5; # niri gaps 5
              extent_presets = [
                0.333
                0.5
                0.667
              ];
              struts = {
                left = 0;
                right = 0;
                top = 0;
                bottom = 0;
              };
              scrolling = {
                default_extent_fraction = 0.5;
                center_underfull_strip = true;
                center_focused = "on_overflow";
              };
              master = {
                position = "left";
                default_width_fraction = 0.55;
                new_on_top = true;
              };
              # dwindle.preserve_split = false; # uncomment to keep split direction
            };

            # Appearance — https://docs.noctalia.dev/umbriel/appearance/
            # Mirrors niri: corner_radius 16, blur, focus-ring #e0a84a / #313244
            appearance = {
              prefer_no_csd = true;
              border_width = 2;
              outer_border_width = 0;
              corner_radius = 16; # niri geometry-corner-radius 16
              drag_opacity = 0.75;
              blur = {
                enabled = true;
                optimized = true;
                passes = 3;
                radius = 3;
                noise = 0.02;
                brightness = 0.9;
                contrast = 0.9;
                saturation = 1.1;
              };
              shadow = {
                enabled = true;
                softness = 10;
                offset_x = 2;
                offset_y = 2;
              };
            };

            # Colors — https://docs.noctalia.dev/umbriel/appearance/#colors
            colors = {
              shadow = "#0000007F"; # was appearance.shadow.color
              # border colors — niri focus-ring active/inactive
              # border.focused = "#e0a84a";
              # border.unfocused = "#313244";
            };

            # Colors — https://docs.noctalia.dev/umbriel/appearance/
            # Leave unset to follow Noctalia sync; example shown:
            # colors = {
            #   background = "#141419FF";
            #   accent_primary = "#e0a84a";
            # };

            # Animation — https://docs.noctalia.dev/umbriel/animation/
            animation = {
              enabled = true;
              duration_ms = 250;
              curve = "easeout";
              windows_in = {
                enabled = true;
                duration_ms = 150;
                curve = "easeout";
                style = "popin";
                scale = 0.85;
              };
              windows_out = {
                enabled = true;
                duration_ms = 150;
                curve = "easeout";
                style = "fade";
              };
              windows_move = {
                enabled = true;
                duration_ms = 250;
                curve = "easeout"; # was snappy — no bounce on close reflow, as you asked
              };
              workspaces = {
                enabled = true;
                duration_ms = 250;
                curve = "snappy"; # was easeout — now snappy for workspace switch
              };
              overview = {
                enabled = true;
                duration_ms = 250;
                curve = "easeout";
              };
            };

            # Overview — https://docs.noctalia.dev/umbriel/workspaces-overview/
            overview = {
              zoom = 0.5;
              # background_blur = true;
            };

            # Input — https://docs.noctalia.dev/umbriel/input/
            # Mirrors niri: keyboard it, cursor Bibata-Modern-Ice 24, Xwayland Satellite
            input = {
              keyboard = {
                layout = ""; # niri input.keyboard.xkb.layout it
                variant = "";
                options = "";
                repeat_rate = 25;
                repeat_delay = 600;
                track_layout = "global";
                numlock_toggle = true;
              };
              touchpad = {
                tap = true;
                natural_scroll = true;
              };
              mouse = {
                sensitivity = 0.0;
                scroll_wheel_step = 60;
              };
              tablet = {
                enabled = lib.mkDefault false;
              };
              cursor = {
                theme = "Bibata-Modern-Ice";
                size = 24;
                hardware_cursor = true;
                follows_focus = true;
                hide_when_typing = true;
                hide_timeout_ms = 3000;
              };
              focus = {
                follows_mouse = true;
                follows_mouse_max_scroll = 0.3;
              };
            };

            environment = {
              "QT_QPA_PLATFORMTHEME" = "qt6ct";
            };
            keybinds =
              let
                noct = lib.getExe pkgs.noctalia;
                nipc = "${noct} msg";
                uipc = "${lib.getExe pkgs.umbriel} msg";
                term = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.neuAlacritty;
              in
              {
                # Window Management
                "Mod+Q" = "window-close";
                "Mod+F" = "window-toggle-maximize";
                "Mod+Shift+F" = "window-toggle-fullscreen";
                "Mod+Ctrl+F" = "window-toggle-maximize-to-edges";

                "Mod+Shift+Space" = "window-toggle-floating";

                "Mod+C" = "column-center";

                "Mod+T" = "spawn:${term}";

                "Mod+E" = "spawn:${term} --class=yazi -e ${lib.getExe pkgs.yazi}";
                "Mod+Shift+E" = "spawn:${lib.getExe pkgs.kdePackages.dolphin}";
                "Mod+B" = "spawn:helium";

                "Mod+Shift+Escape" = "spawn:${term} --class=btop -e ${lib.getExe pkgs.btop}";
                "Mod+Space" = "spawn:${nipc} panel-toggle launcher";

                "Mod+Comma" = "spawn:${nipc} settings-toggle";
                "Mod+Period" = "spawn:${nipc} panel-toggle liamwh/emoji-picker:wide";

                "Mod+R" = "window-cycle-primary-extent";
                # "Mod+Ctrl+R".reset-window-height = [ ];
                # "Mod+Minus".set-column-width = "-10%";
                # "Mod+Equal".set-column-width = "+10%";

                "Mod+Left" = "window-focus-left";
                "Mod+Right" = "window-focus-right";
                "Mod+Up" = "window-focus-up";
                "Mod+Down" = "window-focus-down";

                "Mod+Shift+Left" = "column-move-left";
                "Mod+Shift+Right" = "column-move-right";
                "Mod+Shift+Up" = "window-move-up";
                "Mod+Shift+Down" = "window-move-down";

                "Mod+Ctrl+Left" = "output-focus-left";
                "Mod+Ctrl+Right" = "output-focus-right";
                "Mod+Ctrl+Up" = "output-focus-up";
                "Mod+Ctrl+Down" = "output-focus-down";

                "Mod+Shift+Ctrl+Left" = "column-move-to-output-left";
                "Mod+Shift+Ctrl+Right" = "column-move-to-output-right";
                "Mod+Shift+Ctrl+Up" = "column-move-to-output-up";
                "Mod+Shift+Ctrl+Down" = "column-move-to-output-down";

                "Mod+BracketLeft" = "window-consume-or-expel-left";
                "Mod+BracketRight" = "window-consume-or-expel-right";

                "Mod+1" = "workspace-switch:1";
                "Mod+2" = "workspace-switch:2";
                "Mod+3" = "workspace-switch:3";
                "Mod+4" = "workspace-switch:4";
                "Mod+5" = "workspace-switch:5";
                "Mod+6" = "workspace-switch:6";
                "Mod+7" = "workspace-switch:7";
                "Mod+8" = "workspace-switch:8";
                "Mod+9" = "workspace-switch:9";
                "Mod+Shift+1" = "window-move-to-workspace:1";
                "Mod+Shift+2" = "window-move-to-workspace:2";
                "Mod+Shift+3" = "window-move-to-workspace:3";
                "Mod+Shift+4" = "window-move-to-workspace:4";
                "Mod+Shift+5" = "window-move-to-workspace:5";
                "Mod+Shift+6" = "window-move-to-workspace:6";
                "Mod+Shift+7" = "window-move-to-workspace:7";
                "Mod+Shift+8" = "window-move-to-workspace:8";
                "Mod+Shift+9" = "window-move-to-workspace:9";
                "Mod+Return" = "workspace-set-layout:toggle";

                "Mod+Tab" = "scratchpad-toggle";
                "Mod+Shift+Tab" = "window-toggle-scratchpad";

                "Mod+Minus" = "window-modify-primary-extent:-0.1";
                "Mod+Equal" = "window-modify-primary-extent:0.1";

                "Mod+F1" = "cheatsheet-open";

                "Mod+Slash" = {
                  action = "overview-toggle";
                  repeat = false;
                };
                "Ctrl+Alt+Delete" = "session-quit";
                # "Mod+Comma".spawn-sh = "${ipc} settings toggle";
                # "Mod+L".spawn-sh = "${ipc} lock lock";

                "Print" = "spawn:${nipc} screenshot-region";
                "Ctrl+Print" = "spawn:${nipc} screenshot-fullscreen";
                "Shift+Print" = "spawn:${nipc} screenshot-annotate";

                # Multimedia Keys

                "XF86AudioLowerVolume" = "spawn:${nipc} volume-down";
                "XF86AudioMicMute" = "spawn:${nipc} mic-mute";
                "XF86AudioMute" = "spawn:${nipc} volume-mute";
                "XF86AudioRaiseVolume" = "spawn:${nipc} volume-up";

                "XF86MonBrightnessDown" = "spawn:${nipc} brightness-down";
                "XF86MonBrightnessUp" = "spawn:${nipc} brightness-up";
              };
            layer_rule = [
              {
                match.namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd|desktop-widget-[^\"]*)$";
                blur = true;
                blur_optimized = false;
                blur_popups = true;
                blur_ignore_alpha = 0.5;
              }

            ];
            "window_rule" = [
              {
                "blur" = true;
                "blur_optimized" = false;
              }
              {
                match.app_id = "^dev.noctalia.Noctalia$";
                "default_floating" = true;
                "default_floating_size_px" = { width = 1020; height = 900; };
              }
              {
                match.app_id = "^dev.noctalia.UmbrielSharePicker$";
                "default_floating" = true;
                "default_floating_size_px" = { width = 800; height = 600; };
              }
              {
                match.title = "^(Picture-in-Picture|Picture in picture)$";
                "default_floating" = true;
                "default_maximize" = false;
                default_pinned = true;
                "default_position" = {
                  "x" = 20;
                  "y" = 20;
                  "anchor" = "bottom_right";
                };
              }
              {
                match.title = "^notificationtoasts_.+_desktop";
                "default_position" = {
                  "x" = 0;
                  "y" = 0;
                  "anchor" = "bottom_right";
                };
                "default_focused" = false;
                "default_pinned" = true;
              }
              {
                match.is_alone = true;
                default_maximize = true;
              }
              {
                match.app_id = "^(helium|chromium|zen|firefox)$";
                default_scrolling_extent = 0.75;
              }
              {
                match.app_id = "^(Alacritty|kitty|org\\.gnome\\.Nautilus)$";
                default_scrolling_extent_px = 800;
              }
            ];
          };

          # Noctalia 5.0.1+ now writes correct Umbriel template (colors.border etc.)
          # Previous fix for 5.0.0 removed - it was stripping the new correct keys.
        };
      };
    };
}
