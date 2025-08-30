{ config
, pkgs
, inputs
, lib
, ...
}:
{
  services.pipewire.systemWide = config.hostSpec.isServer;
  services.pipewire.enable = config.hostSpec.isServer;

  systemd.services.snapclient = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.snapcast}/bin/snapclient --host ${if (config.hostSpec.server == "puppetmaster") then "localhost" else "puppetmaster"}";
      Restart = "always";
      RestartSec = 5;
    };
  };
}
