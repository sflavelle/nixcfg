{ inputs, config, lib, pkgs, isNixOS, mainUser, ... }:
let 
  hostName = if isNixOS then config.hostSpec.hostName else false;
in
lib.mkMerge [
  {
    inputs.touchpad.tap = true;
    inputs.touchpad.natural-scroll = true;
    input.focus-follows-mouse.max-scroll-amount = "20%";

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
  }

  # Monitor config
]