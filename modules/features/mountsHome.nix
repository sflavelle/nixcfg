{ self, inputs, ... }: {
  flake.nixosModules.mountsHome = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      cifs-utils
    ];

    fileSystems."/mnt/media" = {
      device = "//10.0.1.1/media";
      fsType = "cifs";
      options = [
        "x-systemd.automount"
        "x-systemd.idle-timeout=60"
        "x-systemd.device-timeout=5s"
        "x-systemd.mount-timeout=5s"
        "credentials=/etc/nixos/smb-secrets"
        "nofail"
        "noauto"
      ];
    };
  };
}
