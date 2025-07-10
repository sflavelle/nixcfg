{
  config,
  pkgs,
  inputs,
  ...
}:
{
  networking.wireless.secretsFile = config.age.secrets.FirelinkShrine.path;
  networking.networkmanager.ensureProfiles.profiles = {
    home = {
      connection = {
        id = "homewifi";
        type = "wifi";
      };
      wifi = {
        mode = "infrastructure";
        ssid = "Firelink Shrine";
      };
      wifi-security = {
        key-mgmt = "wpa-psk";
        pskRaw = "ext:psk_home";
      };
    };
  };
}
