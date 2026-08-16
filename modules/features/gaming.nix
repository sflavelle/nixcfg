{ self, inputs, ... }: {

  flake.nixosModules.gaming = { pkgs, lib, self', ... }: {

      programs.steam = {
        enable = true;
        extest.enable = false;
        localNetworkGameTransfers.openFirewall = true;
        remotePlay.openFirewall = true;
        extraPackages = [pkgs.hidapi];
      };
      hardware.steam-hardware.enable = true;
      programs.gamescope.enable = true;
      programs.gpu-screen-recorder.enable = true;
      

      environment.systemPackages = with pkgs; [
        stuntrally ultimate-stunts bzflag torcs
        lincity armagetronad rocksndiamonds
        torus-trooper apotris xmoto zaz

        tetrio-desktop
        shattered-pixel-dungeon
        space-cadet-pinball
        supermariowar
        ringracers

        uzdoom

        # modding
        balatro-mod-manager

        # emulators
        desmume
        azahar
        dolphin-emu dolphin-emu-primehack
        cemu
        ryubing

        ppsspp
        pcsx2
        rpcs3
        shadps4 shadps4-qtlauncher

        xemu
        xenia-canary

        game-devices-udev-rules
      ];
  
  };
}
