{ inputs, config, lib, pkgs, isNixOS, mainUser, ... }:
let
  hostName = config.hostSpec.hostName;

  commonOptions = {
    layer = "top";
    position = "top";
    height = 24;

    "backlight" = lib.mkIf (config.hostSpec.backlights.monitors != [ ]) {
      device = builtins.baseNameOf (builtins.head config.hostSpec.backlights.monitors);
      format = "{percent}%";
    };

    "battery" = {
      format = "{icon} {capacity}";
      format-icons = [ "" "" "" "" "" ];
      tooltip-format = ''
        {capacity}
        
        Current Draw: {power}
        Battery Capacity: {health}
      '';
    };

    "network" = {
      "format-wifi" = "{essid} ({signalStrength}%) ";
      "format-ethernet" = "{ipaddr}/{cidr} 󰊗";
      "format-disconnected" = "";
      "tooltip-format" = ''
        {ifname}: {ipaddr}
        Gateway: {gwaddr}

        Up: {bandwidthUpBytes}
        Down: {bandwidthDownBytes}
      '';
    };

    "niri/workspaces" = {
      all-outputs = false;
      format = "{icon}";
      format-icons = workspaceIcons;
    };

    "niri/window" = {
      format = "{}";
      separate-ouptuts = true;
    };
    "custom/power" = {
      on-click = "${pkgs.wlogout}/bin/wlogout";
      format = "⏻";
      tooltip = false;
    };
  };

  workspaceIcons = {
    "Browser" = "";
    "Browser (alt)" = "";
    "Work" = "";
    "Games" = "";
    "Code" = "";
    "Audio" = "󱡬";
    "Video" = "󰃽";
    "Communication" = "󰭻";
    "Utility" = "󰧨";
    "Archipelago" = "󱥸";
    "OBS" = "󰑋";

    "default" = "";
  };

in
lib.mkMerge [
  {
    primary = commonOptions // {
      modules-left = [
        "niri/workspaces"
        "niri/window"
      ];
      modules-right = [
        "tray"
        "network"
        "wireplumber"
        (lib.mkIf config.hostSpec.hasBattery "battery")
        (lib.mkIf (config.hostSpec.backlights.monitors != [ ]) "backlight")
        "clock"
        "custom/power"
      ];
    };
  }
]
