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
    mpv-watch
  ];
}
