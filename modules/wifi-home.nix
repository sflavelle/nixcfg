{ config
, pkgs
, lib
, inputs
, ...
}:
{
  # networking.networkmanager.unmanaged = lib.mkIf (config.hostSpec.wirelessInterface != null) [ config.hostSpec.wirelessInterface ];

  networking = {
    networkmanager = {
      wifi.backend = "iwd";
      ensureProfiles = {
        environmentFiles = [
          config.age.secrets.FirelinkShrine.path
        ];
        profiles.home = {
          connection = {
            type = "wifi";
            id = "Firelink Shrine";
          };
          ipv4.method = "auto";
          ipv6 = {
            addr-gen-mode = "stable-privacy";
            method = "auto";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "Firelink Shrine";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$psk_home";
          };
        };
      };
    };

    wireless.interfaces = [ config.hostSpec.wirelessInterface ];
  };

}
