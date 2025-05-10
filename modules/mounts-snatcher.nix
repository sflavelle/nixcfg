{ config, lib, pkgs, ... }:

{
  fileSystems."/home/lily/mnt/extra" = {
    device = "/dev/HDD/lily";
    fsType = "btrfs";
  };
  fileSystems."/mnt/games" = {
    device = "/dev/HDD/games";
    fsType = "btrfs";
  };
}
