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
  fileSystems."/mnt/media" = {
    fsType = "cifs";
    device = "//10.0.0.69/media";
    options = [ "credentials=/home/${config.hostSpec.userName}/.smb-nas"
    "_netdev" "x-systemd.automount" ];
  };
}
