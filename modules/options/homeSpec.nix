{ config
, pkgs
, lib
, inputs
, ...
}:
# This module adapted from
# https://unmovedcentre.com/posts/managing-nix-config-host-variables/

let
  isNixOS = lib.hasAttr "system" config;
  isHomeManager = lib.hasAttr "home" config;
in
{
  options.hostSpec = {
    # Data vars
    userName = lib.mkOption {
      type = lib.types.str;
      default = if config.hostSpec.isPublic then "splatsune" else "lily";
      description = "The username of the host";
    };
    hostName = lib.mkOption {
      type = lib.types.str;
      description = "The hostname of the host";
    };
    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "Australia/Melbourne";
      description = "The geographical timezone the host resides in.";
    };
    home = lib.mkOption {
      type = lib.types.str;
      description = "The home directory of the user";
      default =
        let
          user = config.hostSpec.userName;
        in
        if pkgs.stdenv.isLinux then "/home/${user}" else "/Users/${user}";
    };
    locale = lib.mkOption {
      type = lib.types.str;
      default = "en_AU.UTF-8";
      description = "The locale of the host";
    };
    wallpaper = lib.mkOption {
      type = with lib.types; either path package;
      description = "The main wallpaper for this device";
      default = pkgs.fetchurl {
        url = "https://w.wallhaven.cc/full/1q/wallhaven-1q83qg.jpg"; #retro/vaporwave digital artwork (creatiflux)
        hash = "sha256-QPmG4QTRvubuX6Fy5rmMwYKw4aQdBiH/zGL/PMmUZOk=";
      };
    };
    wirelessInterface = lib.mkOption {
      type = lib.types.str;
      default = null;
      description = "Name of the device's wireless interface, if any";
    };

    # Configurations
    isMinimal = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate a minimal host";
    };
    isHandheld = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used for handheld devices like tablets or gaming handhelds";
    };
    isServer = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate a server host";
    };
    isPublic = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate a host that will be exposed to strangers (laptops etc.)";
    };
    isAutoStyled = lib.mkEnableOption {
      # type = lib.types.bool;
      default = false;
      description = "Used to indicate a host that wants auto styling like stylix";
    };
    hasPhysicalKeyboard = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether this device has a usable physical keyboard - set false to indicate tablets or gaming handhelds";
    };
    hasBattery = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether this device has a battery";
    };
    backlights = {
      monitors = lib.mkOption {
        type = lib.types.listOf (lib.types.str);
        default = [ "/dev/null" ];
        description = "Sys paths to monitor backlights for which to enable brightness control";
      };
      keyboard = lib.mkOption {
        type = lib.types.str;
        default = "/dev/null";
        description = "Sys path to the keyboard backlight device, if any";
      };
    };
  };

  config = { };
}
