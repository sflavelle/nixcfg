{ config, lib, pkgs, ... }:
    {
        enable = true;
        openFirewall = true;
        extraComponents = [ "mqtt" "zeroconf" "whisper" "piper" "tuya" "sonos" "aussie_broadband" ];
        customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
            mushroom
            mini-media-player
        ];
    }
