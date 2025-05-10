{ inputs, config, lib, pkgs, isNixOS, mainUser, ... }:
let
  hostName = config.hostSpec.hostName;

  mapMonitors = monitor: {
    "${monitor.name}" = {
      enable = true;
      mode = {
        height = monitor.height;
        width = monitor.width;
        refresh = monitor.refreshRate;
      };
      position = {
        x = monitor.x;
        y = monitor.y;
      };
      scale = monitor.scale;
      transform.rotation = monitor.transform;
    };
  };

  mappedMonitors = map mapMonitors config.monitors;
in
lib.mkMerge [
  {
    inputs.touchpad.tap = true;
    inputs.touchpad.natural-scroll = true;
    input.focus-follows-mouse.max-scroll-amount = "20%";

    prefer-no-csd = true;

    layout = {
      gaps = 2;
      center-focused-column = "never";
      preset-column-widths = [
        { proportion = 1. / 3.; }
        { proportion = 1. / 2.; }
        { proportion = 2. / 3.; }

        # { fixed = 1080; }
      ];
      default-column-width = [ "proportion 0.33333" ];
      focus-ring = {
        width = 4;
        active-color = "#ff00ff";
        inactive-color = "#ff0000";
      };
      border.enable = false;
      shadow = {
        enable = true;
        color = "#00000070";
        softness = 30;
        spread = 5;
        draw-behind-window = true;
      };
      tab-indicator = {
        enable = true;
        hide-when-single-tab = true;
        place-within-column = true;
        gap = 5;
        width = 4;
        gaps-between-tabs = 2;
        position = "right";
        length.total-proportion = 1.0;
        active-color = "red";
        inactive-color = "gray";
      };

    };

    environment = {
      DISPLAY = ":1";
      QT_QPA_PLATFORM = "wayland";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    };

    binds = with config.lib.niri.actions; let
      browser = "firefox";
      terminal = "${pkgs.ghostty}/bin/ghostty";

      wpctl = "${pkgs.wireplumber}/bin/wpctl";
    in {
      "Mod+T".action.spawn = terminal;
      "Mod+Space".action.spawn = [ "${pkgs.fuzzel}/bin/fuzzel" "--match-mode=fzf" ];
      "Mod+E".action.spawn = [ terminal "-e" "${pkgs.yazi}/bin/yazi" ];
      "Mod+B".action.spawn = [ browser ];
      "Mod+Escape".action.spawn = [ terminal "-e" "${pkgs.btop}/bin/btop" ];

      "XF86AudioRaiseVolume".action.spawn = [ wpctl "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"];
      "XF86AudioLowerVolume".action.spawn = [ wpctl "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"];
      "XF86AudioMute".action.spawn = [ wpctl "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];
      "XF86AudioMicMute".action.spawn = [ wpctl "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"];
      "XF86MonBrightnessUp".action.spawn = [ "pkexec" "${pkgs.brillo}/bin/brillo" "-A" "10" ];
      "XF86MonBrightnessDown".action.spawn = [ "pkexec" "${pkgs.brillo}/bin/brillo" "-U" "10" ];

      "Mod+Q".action = close-window;

      "Mod+Left".action = focus-column-left;
      "Mod+Right".action = focus-column-right;
      "Mod+Up".action = focus-window-up;
      "Mod+Down".action = focus-window-down;

      "Mod+Shift+Left".action = move-column-left;
      "Mod+Shift+Right".action = move-column-right;
      "Mod+Shift+Up".action = move-window-up;
      "Mod+Shift+Down".action = move-window-down;

      "Mod+Ctrl+Left".action = focus-monitor-left;
      "Mod+Ctrl+Right".action = focus-monitor-right;
      "Mod+Ctrl+Up".action = focus-monitor-up;
      "Mod+Ctrl+Down".action = focus-monitor-down;

      "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
      "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;
      "Mod+Shift+Ctrl+Up".action = move-window-to-monitor-up;
      "Mod+Shift+Ctrl+Down".action = move-window-to-monitor-down;

      "Mod+Ctrl+Alt+Left".action = move-workspace-to-monitor-left;
      "Mod+Ctrl+Alt+Right".action = move-workspace-to-monitor-right;
      "Mod+Ctrl+Alt+Up".action = move-workspace-to-monitor-up;
      "Mod+Ctrl+Alt+Down".action = move-workspace-to-monitor-down;

      "Mod+1".action = focus-workspace 1;
      "Mod+2".action = focus-workspace 2;
      "Mod+3".action = focus-workspace 3;
      "Mod+4".action = focus-workspace 4;
      "Mod+5".action = focus-workspace 5;
      "Mod+6".action = focus-workspace 6;
      "Mod+7".action = focus-workspace 7;
      "Mod+8".action = focus-workspace 8;
      "Mod+9".action = focus-workspace 9;
      "Mod+0".action = focus-workspace 10;
      "Mod+Shift+1".action = move-window-to-workspace 1;
      "Mod+Shift+2".action = move-window-to-workspace 2;
      "Mod+Shift+3".action = move-window-to-workspace 3;
      "Mod+Shift+4".action = move-window-to-workspace 4;
      "Mod+Shift+5".action = move-window-to-workspace 5;
      "Mod+Shift+6".action = move-window-to-workspace 6;
      "Mod+Shift+7".action = move-window-to-workspace 7;
      "Mod+Shift+8".action = move-window-to-workspace 8;
      "Mod+Shift+9".action = move-window-to-workspace 9;
      "Mod+Shift+0".action = move-window-to-workspace 10;

      "Mod+BracketLeft".action = consume-or-expel-window-left;
      "Mod+BracketRight".action = consume-or-expel-window-right;

      "Mod+R".action = switch-preset-column-width;
      "Mod+Shift+R".action = switch-preset-column-height;
      "Mod+Ctrl+R".action = reset-window-height;
      "Mod+F".action = maximize-column;
      "Mod+Shift+F".action = fullscreen-window;
      "Mod+Alt+F".action = toggle-windowed-fullscreen;
      "Mod+C".action = center-column;
      "Mod+Minus".action = set-column-width "-10%";
      "Mod+Equal".action = set-column-width "+10%";
      "Mod+Shift+Minus".action = set-window-height "-10%";
      "Mod+Shift+Equal".action = set-window-height "+10%";

      "Mod+Tab".action = switch-focus-between-floating-and-tiling;
      "Mod+Shift+Tab".action = toggle-window-floating;
      "Mod+Alt+Tab".action = toggle-column-tabbed-display;

      "Print".action = screenshot;
      "Ctrl+Print".action = screenshot-screen;
      "Alt+Print".action = screenshot-window;

      "Mod+Period".action = clear-dynamic-cast-target;
      "Mod+Shift+Period".action = set-dynamic-cast-window;
      "Mod+Ctrl+Period".action = set-dynamic-cast-monitor;

      "Ctrl+Alt+Delete".action = quit;
      "Mod+F4".action = quit;
      "Mod+Shift+Return".action = power-off-monitors;

    };
  }

  # Monitor config
  {
    outputs = mappedMonitors;
  }
]
