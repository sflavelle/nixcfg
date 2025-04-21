{
  config,
  pkgs,
  inputs,
  ...
}:

{
  users.users.splatsune.packages = with pkgs; [
    gamemode mangohud ludusavi
    archipelago poptracker steam-devices-udev-rules
    itch heroic 
    shipwright
    lutris 
    xmoto space-cadet-pinball
    tetrio-desktop ringracers osu-lazer
    sgt-puzzles
    shattered-pixel-dungeon
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    protontricks.enable = true;
    gamescopeSession.enable = true;
    
  };
  programs.gamescope.enable = true;

  hardware.opengl.enable = true;
}
