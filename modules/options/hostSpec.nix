{
  config, pkgs, lib, inputs, ...
}:
# This module adapted from 
# https://unmovedcentre.com/posts/managing-nix-config-host-variables/
{
  options.hostSpec = {
    # Data vars
    username = lib.mkOption {
      type = lib.types.str;
      description = "The username of the host";
    };
    hostName = lib.mkOption {
      type = lib.types.str;
      description = "The hostname of the host";
    };
    email = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "The email of the user";
    };
    work = lib.mkOption {
      default = { };
      type = lib.types.attrsOf lib.types.anything;
      description = "An attribute set of work-related information if isWork is true";
    };
    networking = lib.mkOption {
      default = { };
      type = lib.types.attrsOf lib.types.anything;
      description = "An attribute set of networking information";
    };
    wifi = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate if a host has wifi";
    };
    domain = lib.mkOption {
      type = lib.types.str;
      description = "The domain of the host";
    };
    userFullName = lib.mkOption {
      type = lib.types.str;
      description = "The full name of the user";
    };
    handle = lib.mkOption {
      type = lib.types.str;
      description = "The handle of the user (eg: github user)";
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
  }
}