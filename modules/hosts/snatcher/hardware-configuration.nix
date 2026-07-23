{ self, inputs, ...}: {

  flake.nixosModules.snatcherHardware = { config, lib, pkgs, modulesPath, ... }:

  {
    imports =
      [ (modulesPath + "/installer/scan/not-detected.nix")
      ];

    boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/f06aad81-4303-4646-8baf-56aab599a80f";
        fsType = "btrfs";
      };

    fileSystems."/home" =
      { device = "/dev/disk/by-uuid/8a82765f-e064-4be2-99c9-f844900d61d3";
        fsType = "btrfs";
      };

    fileSystems."/mnt/misc" =
      { device = "/dev/disk/by-uuid/48b4c5b8-98b4-4f88-bf11-ad2ac38f33d4";
        fsType = "btrfs";
      };

    fileSystems."/mnt/games" =
      { device = "/dev/disk/by-uuid/9b6bbb91-2491-4937-a472-112773401d89";
        fsType = "btrfs";
      };

    fileSystems."/nix" =
      { device = "/dev/disk/by-uuid/f06aad81-4303-4646-8baf-56aab599a80f";
        fsType = "btrfs";
        options = [ "subvol=nix" ];
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/FA7B-7B31";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

    swapDevices =
      [ { device = "/dev/disk/by-uuid/fd619371-497c-4150-8a03-7ece73a4058b"; }
      ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

}
