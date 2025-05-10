{
  config,
  pkgs,
  inputs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    ungoogled-chromium
    snapcast
    # (callPackage ../pkgs/mpv-watch.nix)
  ];

  services.flatpak.enable = true;

  programs.firefox.enable = true;
}
