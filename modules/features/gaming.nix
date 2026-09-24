{ self, inputs, ... }: {

  flake.nixosModules.gaming = { pkgs, lib, self', ... }: {

      nixpkgs.overlays = [ inputs.millennium.overlays.default ];

      programs.steam = {
        enable = true;
        package = pkgs.millennium-steam;
        extest.enable = false;
        localNetworkGameTransfers.openFirewall = true;
        remotePlay.openFirewall = true;
        extraPackages = [pkgs.hidapi];
      };
      hardware.steam-hardware.enable = true;
      programs.gamescope.enable = true;
      programs.gpu-screen-recorder = {
        enable = true;
        ui.enable = true;
      };


      environment.systemPackages = with pkgs; [
        stuntrally ultimatestunts bzflag torcs
        lincity armagetronad rocksndiamonds
        torus-trooper apotris xmoto zaz

        tetrio-desktop osu-lazer-bin
        shattered-pixel-dungeon
        space-cadet-pinball
        supermariowar
        ringracers

        openttd vcmi

        uzdoom

        openspeedrun

        # modding
        balatro-mod-manager
        r2modman
        beammp-launcher
        satisfactorymodmanager ficsit-cli

        # emulators
        desmume
        # azahar
        dolphin-emu dolphin-emu-primehack
        cemu
        ryubing

        ppsspp
        # pcsx2
        # rpcs3
        shadps4 shadps4-qtlauncher

        xemu
        xenia-canary

        protonplus 
        steam-rom-manager steam-art-manager

        lutris

        game-devices-udev-rules
      ];
  
  };
}
