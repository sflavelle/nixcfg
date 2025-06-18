{ inputs, config, lib, isNixOS, mainUser, ... }:
let
  hostName = config.hostSpec.hostName;

  bg = "#150923";
  bg-light = "#261d1e";
  fg = "#f0dedf";
  active = "#ffb2bc";
  inactive = "#d7c1c3";
in
  ''
    * {
      background-color: transparent;
      font-family: Determination Sans, Symbols Nerd Font Mono, DINish;
      font-size: 1rem;
      border-radius: 1rem;
    }

    #workspaces button {
      background-color: ${bg}; 
      color: ${fg};
      border-radius: 1rem;
      padding: 0 0.75rem;
      transition: 0.3s;
    }

    #workspaces button.empty {
      color: darken(${fg}, 30%);
    }

    #workspaces button:hover {
      background-color: lighten(${bg}, 10%);
    }

    #workspaces button.active {
      background-color: ${active};
      color: ${bg};
    }

    #clock {
      font-size: 1.1rem;
      margin-right: 0.5rem;
      padding: 0 0.5rem;
      background-color: #886666ee;
    }

  ''
