{ config
, pkgs
, inputs
, ...
}:
let
  mediaDrive = "/mnt/media";
in
{
  services.transmission = {
    enable = true;
    openFirewall = true;
    openRPCPort = true;
    settings = {
      rpc-bind-address = "0.0.0.0";
      rpc-whitelist = "127.0.0.1,10.0.*.*,192.168.192.*";
      rpc-port = 8100;
      download-dir = "${mediaDrive}/Downloads/Torrents";
    };
    downloadDirPermissions = "777";
  };

  services.jackett = {
    # Indexer manager/proxy
    enable = true;
    openFirewall = true;
    port = 8787;
  };

  services.bazarr = {
    enable = true;
    openFirewall = true;
    listenPort = 6767;
  };

  services.sonarr = {
    enable = true;
    openFirewall = true;
    settings = {
      server.bindaddress = "*";
      server.port = 8989;
    };
  };
  services.radarr = {
    enable = true;
    openFirewall = true;
    settings = {
      server.bindaddress = "*";
      server.port = 7878;
    };
  };
}
