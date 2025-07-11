{
  config,
  pkgs,
  inputs,
  ...
}:
{
  networking.networkmanager.unmanaged = [ config.hostSpec.wirelessInterface ];

  networking.wireless.enable = config.hostSpec.wirelessInterface != null;
  networking.wireless.secretsFile = config.age.secrets.FirelinkShrine.path;
  networking.wireless.networks = {
    "FirelinkShrine" = {
      pskRaw = "ext:psk_home";
  }
}
