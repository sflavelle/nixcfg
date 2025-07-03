{ inputs, config, lib, isNixOS, mainUser, ... }:

''
  * {
    border: none;
    border-radius: 0;
    /* `otf-font-awesome` is required to be installed for icons */
    font-family: Determination Sans, Symbols Nerd Font Mono;
    font-size: 16px;
    min-height: 20px;
  }

  window#waybar {
      background: transparent;
      color: @base05;
  }

  window#waybar.hidden {
      opacity: 0.2;
  }

  #window {
    text-shadow: 1px 1px 6px black;
    color: #ffffff;
  }

  #workspaces {
      margin-right: 8px;
      border-radius: 10px;
      transition: none;
      background: @base00;
  }

  #workspaces button {
      transition: none;
      color: #7c818c;
      background: transparent;
      padding: 5px;
      font-size: 18px;
  }

  #workspaces button.persistent {
      color: #7c818c;
      font-size: 12px;
  }

  /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
  #workspaces button:hover {
      transition: none;
      box-shadow: inherit;
      text-shadow: inherit;
      border-radius: inherit;
      color: #383c4a;
      background: @base01;
  }

  #workspaces button.focused {
      background: @base02;
      color: white;
  }

  #language {
      padding-left: 16px;
      padding-right: 8px;
      border-radius: 10px 0px 0px 10px;
      transition: none;
      color: #ffffff;
      background: #383c4a;
  }

  #keyboard-state {
      margin-right: 8px;
      padding-right: 16px;
      border-radius: 0px 10px 10px 0px;
      transition: none;
      color: #ffffff;
      background: #383c4a;
  }

  #custom-pacman {
      padding-left: 16px;
      padding-right: 8px;
      border-radius: 10px 0px 0px 10px;
      transition: none;
      color: #ffffff;
      background: #383c4a;
  }

  #custom-mail {
      margin-right: 8px;
      padding-right: 16px;
      border-radius: 0px 10px 10px 0px;
      transition: none;
      color: #ffffff;
      background: #383c4a;
  }

  #mode {
      padding-left: 16px;
      padding-right: 16px;
      border-radius: 10px;
      transition: none;
      color: #ffffff;
      background: #383c4a;
  }

  #clock {
      padding-left: 16px;
      padding-right: 16px;
      border-radius: 10px;
      transition: none;
      color: @base05;
      background: @base00;
  }

  #custom-weather {
      padding-right: 16px;
      border-radius: 0px 10px 10px 0px;
      transition: none;
      color: @base05;
      background: @base01;
  }

  #wireplumber {
      margin-right: 8px;
      padding-left: 16px;
      padding-right: 16px;
      border-radius: 10px;
      transition: none;
      color: @base05;
      background: @base01;
  }

  #wireplumber.muted {
      margin-right: 8px;
      padding-left: 16px;
      padding-right: 16px;
      border-radius: 10px;
      background-color: @base09;
      color: @base05;
  }

  #custom-mem {
      margin-right: 8px;
      padding-left: 16px;
      padding-right: 16px;
      border-radius: 10px;
      transition: none;
      color: @base05;
      background: @base01;
  }

  #network {
      margin-right: 8px;
      padding-left: 16px;
      padding-right: 16px;
      border-radius: 10px;
      transition: none;
      color: @base05;
      background: @base01;
  }

  #temperature {
      margin-right: 8px;
      padding-left: 16px;
      padding-right: 16px;
      border-radius: 10px;
      transition: none;
      color: @base05;
      background: @base01;
  }

  #temperature.critical {
      background-color: @base09;
  }

  #backlight {
      margin-right: 8px;
      padding-left: 16px;
      padding-right: 16px;
      border-radius: 10px;
      transition: none;
      color: @base05;
      background: @base01;
  }

  #battery {
      margin-right: 8px;
      padding-left: 16px;
      padding-right: 16px;
      border-radius: 10px;
      transition: none;
      color: @base05;
      background: @base01;
  }

  #battery.charging {
      color: @base05;
      background-color: #26A65B;
  }

  #battery.warning:not(.charging) {
      background-color: #ffbe61;
      color: black;
  }

  #battery.critical:not(.charging) {
      background-color: #f53c3c;
      color: #ffffff;
      animation-name: blink;
      animation-duration: 0.5s;
      animation-timing-function: linear;
      animation-iteration-count: infinite;
      animation-direction: alternate;
  }

  #tray {
      padding-left: 16px;
      padding-right: 16px;
      border-radius: 10px;
      transition: none;
      color: #ffffff;
      background: @base01;
  }

  #custom-power {
    background: transparent;
    color: #f53c3c;
    padding-left: 16px;
    padding-right: 16px;
  }

  @keyframes blink {
      to {
          background-color: #ffffff;
          color: #000000;
      }
  }

''
