{ inputs, config, lib, pkgs, isNixOS, mainUser, ... }:
let
  hostName = config.hostSpec.hostName;

  mapMonitors = monitor: {
    "${monitor.name}" = {
      enable = true;
      mode = {
        height = monitor.height;
        width = monitor.width;
        # refresh = monitor.refreshRate;
      };
      position = {
        x = monitor.x;
        y = monitor.y;
      };
      scale = monitor.scale;
      transform.rotation = monitor.transform;
    };
  };

  mappedMonitors = if config ? monitors then lib.attrsets.mergeAttrsList (map mapMonitors config.monitors) else {};
in
lib.mkMerge [
  {
    input.touchpad.tap = true;
    input.touchpad.natural-scroll = true;
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
      default-column-width.proportion = 1. / 3.;
      focus-ring = {
        width = 4;
        active.color = "rgb(255 0 255)";
        inactive.color = "rgb(0 0 0)";
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
        active.color = "red";
        inactive.color = "gray";
      };

    };

    environment = {
      DISPLAY = ":1";
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    };

    binds = 
      # with config.lib.niri.actions; 
    let
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

      "Mod+Q".action.close-window = true;

      "Mod+Left".action.focus-column-left = true;
      "Mod+Right".action.focus-column-right = true;
      "Mod+Up".action.focus-window-up = true;
      "Mod+Down".action.focus-window-down = true;

      "Mod+Shift+Left".action.move-column-left = true;
      "Mod+Shift+Right".action.move-column-right = true;
      "Mod+Shift+Up".action.move-window-up = true;
      "Mod+Shift+Down".action.move-window-down = true;

      "Mod+Ctrl+Left".action.focus-monitor-left = true;
      "Mod+Ctrl+Right".action.focus-monitor-right = true;
      "Mod+Ctrl+Up".action.focus-monitor-up = true;
      "Mod+Ctrl+Down".action.focus-monitor-down = true;

      "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = true;
      "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = true;
      "Mod+Shift+Ctrl+Up".action.move-window-to-monitor-up = true;
      "Mod+Shift+Ctrl+Down".action.move-window-to-monitor-down = true;

      "Mod+Ctrl+Alt+Left".action.move-workspace-to-monitor-left = true;
      "Mod+Ctrl+Alt+Right".action.move-workspace-to-monitor-right = true;
      "Mod+Ctrl+Alt+Up".action.move-workspace-to-monitor-up = true;
      "Mod+Ctrl+Alt+Down".action.move-workspace-to-monitor-down = true;

      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+5".action.focus-workspace = 5;
      "Mod+6".action.focus-workspace = 6;
      "Mod+7".action.focus-workspace = 7;
      "Mod+8".action.focus-workspace = 8;
      "Mod+9".action.focus-workspace = 9;
      "Mod+0".action.focus-workspace = 10;
      "Mod+Shift+1".action.move-window-to-workspace = 1;
      "Mod+Shift+2".action.move-window-to-workspace = 2;
      "Mod+Shift+3".action.move-window-to-workspace = 3;
      "Mod+Shift+4".action.move-window-to-workspace = 4;
      "Mod+Shift+5".action.move-window-to-workspace = 5;
      "Mod+Shift+6".action.move-window-to-workspace = 6;
      "Mod+Shift+7".action.move-window-to-workspace = 7;
      "Mod+Shift+8".action.move-window-to-workspace = 8;
      "Mod+Shift+9".action.move-window-to-workspace = 9;
      "Mod+Shift+0".action.move-window-to-workspace = 10;

      "Mod+BracketLeft".action.consume-or-expel-window-left = true;
      "Mod+BracketRight".action.consume-or-expel-window-right = true;

      "Mod+R".action.switch-preset-column-width = true;
      "Mod+Shift+R".action.switch-preset-column-height = true;
      "Mod+Ctrl+R".action.reset-window-height = true;
      "Mod+F".action.maximize-column = true;
      "Mod+Shift+F".action.fullscreen-window = true;
      "Mod+Alt+F".action.toggle-windowed-fullscreen = true;
      "Mod+C".action.center-column = true;
      "Mod+Minus".action.set-column-width = "-10%";
      "Mod+Equal".action.set-column-width = "+10%";
      "Mod+Shift+Minus".action.set-window-height = "-10%";
      "Mod+Shift+Equal".action.set-window-height = "+10%";

      "Mod+Tab".action.switch-focus-between-floating-and-tiling = true;
      "Mod+Shift+Tab".action.toggle-window-floating = true;
      "Mod+Alt+Tab".action.toggle-column-tabbed-display = true;

      "Print".action.screenshot = true;
      "Ctrl+Print".action.screenshot-screen = true;
      "Alt+Print".action.screenshot-window = true;

      "Mod+Period".action.clear-dynamic-cast-target = true;
      "Mod+Shift+Period".action.set-dynamic-cast-window = true;
      "Mod+Ctrl+Period".action.set-dynamic-cast-monitor = true;

      "Ctrl+Alt+Delete".action.quit = true;
      "Mod+F4".action.quit = true;
      "Mod+Shift+Return".action.power-off-monitors = true;

    };
  }

  # Monitor config
  {
    outputs = mappedMonitors;
  }
]