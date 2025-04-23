{
  disko.devices = {
    disk = {
      chromebook = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              end = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
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
  };
}
