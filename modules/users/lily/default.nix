{ lib, ... }:
let
  mainUser = config.hostSpec.username;
  name = if config.hostSpec.isPublic then "Simon Flavelle" else "Lily Flavelle"; # yes i'm not out yet
in
{
  imports = lib.custom.scanPaths ./.;

  users.users."${mainUser}" = {
    isNormalUser = true;
    initialHashedPassword = "$y$j9T$YtsEpAHJxRS/EyGrxjdC3.$p5EZjR9.344Xu2kVHyB.RLLGLetkSD/oT1Me8UbX3x4";
    description = name;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; lib.mkMerge [
      ([ # All systems

      ])
      (mkIf config.hostSpec.hasPhysicalKeyboard [

      ])
    ]
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users."${mainUser}" = {
      
    }
  }
}