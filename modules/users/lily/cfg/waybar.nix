{ inputs, config, lib, pkgs, isNixOS, mainUser, ... }:
let
  hostName = config.hostSpec.hostName;

  commonOptions = {
    layer = "top";
    position = "top";
    height = 24;

    "niri/workspaces" = {
      all-outputs = false;
      format = "{icon}";
      format-icons = workspaceIcons;
    };

    "niri/window" = {
      format = "{}";
      separate-ouptuts = true;
    };
  };

  workspaceIcons = {
    "Browser" = "";
    "Browser (alt)" = "";
    "Games" = "";
    "Code" = "";
    "Audio" = "󱡬";
    "Video" = "󰃽";
    "Communication" = "󰭻";
    "OBS" = "󰑋";

    "default" = "";
  };

in
lib.mkMerge [
  {
    primary = {
      inherit commonOptions;
      modules-left = [
        "niri/workspaces"
        "niri/window"
      ];
      modules-right = [
        "tray"
        "wireplumber"
        "clock"
      ];
    };
  }
]
