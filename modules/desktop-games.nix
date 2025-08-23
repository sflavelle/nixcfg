{ config
, pkgs
, inputs
, ...
}:

{
  imports = [
    inputs.aagl.nixosModules.default
  ];

  environment.systemPackages = with pkgs; [
    gamemode
    mangohud
    ludusavi
    archipelago
    poptracker
    steam-devices-udev-rules
    itch
    heroic
    shipwright
    lutris
    xmoto
    space-cadet-pinball
    tetrio-desktop
    ringracers
    osu-lazer-bin
    celeste64
    sgt-puzzles
    shattered-pixel-dungeon
    gzdoom

    cemu
    ryubing
    pcsx2
    rpcs3

    steam-rom-manager
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    protontricks.enable = true;
    gamescopeSession.enable = true;

  };
  programs.gamescope.enable = true;

  programs.anime-games-launcher.enable = true;

  hardware.graphics.enable = true;

  hardware.xone.enable = true;
}
