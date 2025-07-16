{ config
, pkgs
, inputs
, ...
}:
{
  environment.systemPackages = with pkgs; [
    ungoogled-chromium
    snapcast
    # (callPackage ../pkgs/mpv-watch.nix)
    rmpc

    streamlink
    twitch-tui
  ];
  environment.variables = {
    MPD_HOST = "puppetmaster";
  };

  services.flatpak.enable = true;

  programs.firefox.enable = true;
}
