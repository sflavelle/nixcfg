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
    input.focus-follows-mouse.enable = true;
    input.focus-follows-mouse.max-scroll-amount = "20%";
    input.power-key-handling.enable = false; # Too many accidental sleeps on laptops...

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

    window-rules = [
      {
        matches = [
          { 
            app-id = "firefox";
            title = "Picture-in-Picture";
          }
        ];
        open-floating = true;
        default-floating-position = {
          relative-to = "bottom-right";
          x = 0;
          y = 0;
        };
      }
    ];

    spawn-at-startup = [
      # { command = ["${pkgs.waybar}/bin/waybar"]; }
      # { command = ["${pkgs.mako}/bin/mako"]; }
      { command = ["ignis" "init"]; }
      { command = ["${pkgs.xwayland-satellite}/bin/xwayland-satellite" ":1"]; }
    ];

    binds = 
      # with config.lib.niri.actions; 
    let
      browser = "firefox";
      terminal = "${pkgs.alacritty}/bin/alacritty";
      launcher = [ "${pkgs.bemenu}/bin/bemenu-run" "-ib" "--fn" "Determination Sans 14" ];

      wpctl = "${pkgs.wireplumber}/bin/wpctl";
      pwvucontrol = "${pkgs.pwvucontrol}/bin/pwvucontrol";
    in {
      "Mod+T".action.spawn = terminal;
      "Mod+Space".action.spawn = launcher;
      "Mod+Space".hotkey-overlay.title = "Run Command";
      "Mod+E".action.spawn = [ terminal "-e" "${pkgs.yazi}/bin/yazi" ];
      "Mod+E".hotkey-overlay.title = "File Manager (Yazi)";
      "Mod+Shift+E".action.spawn = [ terminal "-e" "${pkgs.cosmic-files}/bin/cosmic-files" ];
      "Mod+Shift+E".hotkey-overlay.title = "File Manager (COSMIC Files)";
      "Mod+B".action.spawn = [ browser ];
      "Mod+Escape".action.spawn = [ terminal "-e" "${pkgs.btop}/bin/btop" ];
      "Mod+Escape".hotkey-overlay.title = "System Monitor";
      "Mod+F1".action.show-hotkey-overlay = [];

      "Mod+Grave".action.spawn = [ pwvucontrol ];
      "Mod+Grave".hotkey-overlay.title = "PulseAudio Volume Control";
      "XF86AudioRaiseVolume".action.spawn = [ wpctl "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"];
      "XF86AudioRaiseVolume".hotkey-overlay.title = "Volume Up";
      "XF86AudioLowerVolume".action.spawn = [ wpctl "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"];
      "XF86AudioLowerVolume".hotkey-overlay.title = "Volume Down";
      "XF86AudioMute".action.spawn = [ wpctl "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];
      "XF86AudioMute".hotkey-overlay.title = "Mute Audio";
      "XF86AudioMicMute".action.spawn = [ wpctl "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"];
      "XF86MonBrightnessUp".action.spawn = [ "pkexec" "${pkgs.brillo}/bin/brillo" "-A" "10" ];
      "XF86MonBrightnessUp".hotkey-overlay.title = "Brightness Up";
      "XF86MonBrightnessDown".action.spawn = [ "pkexec" "${pkgs.brillo}/bin/brillo" "-U" "10" ];
      "XF86MonBrightnessDown".hotkey-overlay.title = "Brightness Down";

      "Mod+Q".action.close-window = [];

      "Mod+Left".action.focus-column-left = [];
      "Mod+Right".action.focus-column-right = [];
      "Mod+Up".action.focus-window-up = [];
      "Mod+Down".action.focus-window-down = [];

      "Mod+Shift+Left".action.move-column-left = [];
      "Mod+Shift+Right".action.move-column-right = [];
      "Mod+Shift+Up".action.move-window-up = [];
      "Mod+Shift+Down".action.move-window-down = [];

      "Mod+Ctrl+Left".action.focus-monitor-left = [];
      "Mod+Ctrl+Right".action.focus-monitor-right = [];
      "Mod+Ctrl+Up".action.focus-monitor-up = [];
      "Mod+Ctrl+Down".action.focus-monitor-down = [];

      "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [];
      "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [];
      "Mod+Shift+Ctrl+Up".action.move-window-to-monitor-up = [];
      "Mod+Shift+Ctrl+Down".action.move-window-to-monitor-down = [];

      "Mod+Ctrl+Alt+Left".action.move-workspace-to-monitor-left = [];
      "Mod+Ctrl+Alt+Right".action.move-workspace-to-monitor-right = [];
      "Mod+Ctrl+Alt+Up".action.move-workspace-to-monitor-up = [];
      "Mod+Ctrl+Alt+Down".action.move-workspace-to-monitor-down = [];

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

      "Mod+BracketLeft".action.consume-or-expel-window-left = [];
      "Mod+BracketRight".action.consume-or-expel-window-right = [];

      "Mod+R".action.switch-preset-column-width = [];
      "Mod+Ctrl+R".action.reset-window-height = [];
      "Mod+F".action.maximize-column = [];
      "Mod+Shift+F".action.fullscreen-window = [];
      "Mod+Alt+F".action.toggle-windowed-fullscreen = [];
      "Mod+C".action.center-column = [];
      "Mod+Minus".action.set-column-width = "-10%";
      "Mod+Equal".action.set-column-width = "+10%";
      "Mod+Shift+Minus".action.set-window-height = "-10%";
      "Mod+Shift+Equal".action.set-window-height = "+10%";

      "Mod+Tab".action.switch-focus-between-floating-and-tiling = [];
      "Mod+Shift+Tab".action.toggle-window-floating = [];
      "Mod+Alt+Tab".action.toggle-column-tabbed-display = [];

      "Print".action.screenshot = [];
      "Ctrl+Print".action.screenshot-screen = [];
      "Alt+Print".action.screenshot-window = [];

      "Mod+Period".action.clear-dynamic-cast-target = [];
      "Mod+Shift+Period".action.set-dynamic-cast-window = [];
      "Mod+Ctrl+Period".action.set-dynamic-cast-monitor = [];

      "Mod+Slash".action.toggle-overview = [];

      "Ctrl+Alt+Delete".action.spawn = [ "${pkgs.wlogout}/bin/wlogout" ];
      "Ctrl+Alt+Delete".hotkey-overlay.title = "Power Menu";
      "Mod+F4".action.quit = [];
      "Mod+Shift+Return".action.power-off-monitors = [];

    };
  }

  # Monitor config
  {
    outputs = mappedMonitors;
  }

  # Per-host workspace config
  (lib.mkIf (config.hostSpec.hostName == "snatcher") {
    input.touch.map-to-output = "HDMI-A-1";

    spawn-at-startup = [
      { command = ["steam"]; }
      { command = ["webcord"]; }
    ];

    workspaces = {
      "main-01-browser" = {
        open-on-output = "DP-2";
        name = "Browser";
      };
      "main-02-games" = {
        open-on-output = "DP-2";
        name = "Games";
      };
      "main-03-dev" = {
        open-on-output = "DP-2";
        name = "Code";
      };
      "main-04-audio" = {
        open-on-output = "DP-2";
        name = "Audio";
      };
      "left-01-browser-alt" = {
        open-on-output = "DP-1";
        name = "Browser (alt)";
      };
      "left-02-video" = {
        open-on-output = "DP-1";
        name = "Video";
      };
      "right-01-communication" = {
        open-on-output = "HDMI-A-2";
        name = "Communication";
      };
      "down-01-utility" = {
        open-on-output = "HDMI-A-1";
        name = "Utility";
      };
    };

    window-rules = [
      # {
      #   matches = [
      #     { app-id = "firefox"; }
      #   ];
      #   open-on-workspace = "Browser";
      # }
      {
        matches = [
          { app-id = "^steam$"; }
        ];
        open-on-workspace = "Games";

      }
      {
        matches = [
          { app-id = "^steam_app_"; }
          { app-id = "gzdoom"; }
          { app-id = "SpaceIdle"; }
          { title = "Ship of Harkinian"; }
          { app-id = "Celeste"; }
        ];
        open-on-workspace = "Games";
        default-column-width = {};

      }
      {
        matches = [
          { app-id = "^code$"; title = "Visual Studio Code";}
        ];
        open-on-workspace = "Code";

      }
      {
        matches = [
          { app-id = "discord"; }
          { app-id = "WebCord"; }
          { app-id = "element"; }
        ];
        open-on-workspace = "Communication";
      }
      {
        matches = [
          { app-id = "vlc"; }
          { app-id = "mpv"; }
          { app-id = "obs-studio"; }
          { app-id = "jellyfin-media-player"; }
        ];
        open-on-workspace = "Video";
        open-fullscreen = true;
      }
    ];
  })
]