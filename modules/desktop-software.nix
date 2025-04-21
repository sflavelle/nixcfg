{
  config,
  pkgs,
  inputs,
  ...
}:
{
  users.users."splatsune".packages = with pkgs; [
    ungoogled-chromium
    snapcast
    (callPackage ../pkgs/mpv-watch.nix)
  ];
}
