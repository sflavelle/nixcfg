{
  disko.devices.disk.root = {
    device = "/dev/sda";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          type = "EF00";
          size = "512M";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            subvolumes."/root".mountpoint = "/";
            subvolumes."/home" = {
              mountOptions = [ "compress=zstd" ];
              mountpoint = "/home";
            };
            subvolumes."/nix" = {
              mountOptions = [ "compress=zstd" "noatime" ];
              mountpoint = "/nix";
            };
          };
        };
      };
    };
  };
}
