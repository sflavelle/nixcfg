{ config, lib, pkgs, ... }:

{
  fileSystems."/home/lily/mnt/extra" = {
    device = "/dev/HDD/lily";
    fsType = "btrfs";
    options = [ "defaults" "noatime" "compress=zstd" "x-systemd.automount" ];
  };
  fileSystems."/mnt/games" = {
    device = "/dev/HDD/games";
    fsType = "btrfs";
    options = [ "defaults" "noatime" "compress=zstd" "x-systemd.automount" ];
  };
  fileSystems."/mnt/media" = {
    fsType = "cifs";
    device = "//10.0.0.69/media";
    options = [ "credentials=/home/${config.hostSpec.userName}/.smb-nas"
    "_netdev" "x-systemd.automount" "uid=1000" "gid=100" ];
  };
}
