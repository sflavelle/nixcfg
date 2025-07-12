{ inputs, config, lib, pkgs, ... }:
{

  imports = [
  ];

  users.users.juno = {
    isNormalUser = true;
    initialHashedPassword = "$y$j9T$iC7zeumv8l6cduG2OxBnJ0$9yIb9ielE6xklkoAZac.XzrhWnqOjJrVELPKoNh5ikA";
    description = "Juno The Trinity";
    extraGroups = [
      "networkmanager"
    ];
    packages = with pkgs; lib.mkMerge [
      ([
        # All systems

      ])
      (lib.mkIf config.hostSpec.hasPhysicalKeyboard [

      ])
    ];
  };

  #  home-manager.users.juno = ./home.nix;

}
