{
  config,
  pkgs,
  inputs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    gamemode mangohud ludusavi
    archipelago stable.poptracker steam-devices-udev-rules
    itch heroic
    shipwright
    lutris
    xmoto space-cadet-pinball
    tetrio-desktop ringracers osu-lazer-bin
    sgt-puzzles
    shattered-pixel-dungeon
    stable.gzdoom
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    protontricks.enable = true;
    gamescopeSession.enable = true;

  };
  programs.gamescope.enable = true;

  hardware.graphics.enable = true;
}
