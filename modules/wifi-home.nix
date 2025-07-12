{ config
, pkgs
, lib
, inputs
, ...
}:
{
  networking.networkmanager.unmanaged = lib.mkIf (config.hostSpec.wirelessInterface != null) [ config.hostSpec.wirelessInterface ];

  networking.wireless.enable = config.hostSpec.wirelessInterface != null;
  networking.wireless.secretsFile = config.age.secrets.FirelinkShrine.path;
  networking.wireless.networks = {
    "FirelinkShrine" = {
      pskRaw = "ext:psk_home";
    };
  };
}
