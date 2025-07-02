{ inputs, outputs, config, lib, pkgs, ... }:
let
  mainUser = config.hostSpec.userName;
  name = if config.hostSpec.isPublic then "Simon Flavelle" else "Lily Flavelle"; # yes i'm not out yet
in
{
  nix.settings.trusted-users = [ mainUser ];
  users.users."${mainUser}" = {
    isNormalUser = true;
    initialHashedPassword = "$y$j9T$YtsEpAHJxRS/EyGrxjdC3.$p5EZjR9.344Xu2kVHyB.RLLGLetkSD/oT1Me8UbX3x4";
    description = name;
    extraGroups = [
      "networkmanager"
      "wheel"
      "pipewire"
      "dialout"
    ];
  };

  home-manager.users."${mainUser}" = import ./home.nix {
    inherit config lib pkgs inputs outputs;
    inherit mainUser name;
  };

}
