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
      type - lib.types.str;
      default = "Australia/Melbourne";
      description = "The geographical timezone the host resides in.";
    };
    home = lib.mkOption {
      type = lib.types.str;
      description = "The home directory of the user";
      default =
        let
          user = config.hostSpec.username;
        in
        if pkgs.stdenv.isLinux then "/home/${user}" else "/Users/${user}";
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
      description = "Whether a device has a usable physical keyboard - set false to indicate tablets or gaming handhelds";
    };
  };

  config = {
    networking.hostName = config.hostSpec.hostName;
    time.timeZone = config.hostSpec.timeZone;

    environment.enableAllTerminfo = true;
  };
}
