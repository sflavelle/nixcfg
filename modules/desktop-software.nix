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

  programs.firefox.enable = true;
}
