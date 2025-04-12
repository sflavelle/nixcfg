{
  config,
  pkgs,
  inputs,
  ...
}:

{
  users.users.splatsune.packages = with pkgs; [
    gamemode mangohud
    archipelago poptracker steam-devices-udev-rules
    itch heroic 
    shipwright
    lutris 
    stuntrally xmoto space-cadet-pinball
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

  hardware.opengl.enable = true;
}
