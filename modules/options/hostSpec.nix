{
  config, pkgs, lib, inputs, ...
}:
# This module adapted from
# https://unmovedcentre.com/posts/managing-nix-config-host-variables/
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
    isAutoStyled = lib.mkOption {
      type = lib.types.bool;
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
    hasWifi = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this device has a wifi card";
    };
    backlights = {
      monitors = lib.mkOption {
        type = lib.types.listOf (lib.types.str);
        default = [];
        description = "Sys paths to monitor backlights for which to enable brightness control";
      };
      keyboard = lib.mkOption {
        type = lib.types.str;
        default = null;
        description = "Sys path to the keyboard backlight device, if any";
      };
    };
  };

  config = {
    networking.hostName = config.hostSpec.hostName;
    time.timeZone = config.hostSpec.timeZone;

    networking.networkmanager.enable = true;
    # networking.wireless.enable = config.hostSpec.hasWifi;

    i18n.defaultLocale = config.hostSpec.locale;

    i18n.extraLocaleSettings = {
      LC_ADDRESS = config.hostSpec.locale;
      LC_IDENTIFICATION = config.hostSpec.locale;
      LC_MEASUREMENT = config.hostSpec.locale;
      LC_MONETARY = config.hostSpec.locale;
      LC_NAME = config.hostSpec.locale;
      LC_NUMERIC = config.hostSpec.locale;
      LC_PAPER = config.hostSpec.locale;
      LC_TELEPHONE = config.hostSpec.locale;
      LC_TIME = config.hostSpec.locale;
    };

    environment.enableAllTerminfo = true;

    services.power-profiles-daemon.enable = !config.hostSpec.hasBattery;
    services.auto-cpufreq = {
      enable = config.hostSpec.hasBattery;
      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };

    stylix = {
      enable = config.hostSpec.isAutoStyled;
      # base16Scheme = "${pkgs.base16-schemes}/share/themes/tarot.yaml";
      image = config.hostSpec.wallpaper;
    };

  };
}
