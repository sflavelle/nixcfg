{
  config,
  pkgs,
  inputs,
  ...
}:

{
  users.users.splatsune.packages = with pkgs; [
    gamemode
    archipelago poptracker steam-devices-udev-rules
    itch heroic 
    shipwright
    lutris 
    torus-trooper stuntrally xmoto space-cadet-pinball
    tetrio-desktop ringracers gzdoom
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    protontricks.enable = true;
    gamescopeSession.enable = true;
    
  };
  programs.gamescope.enable = true;
}