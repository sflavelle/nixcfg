{ self, inputs, ... }: {

  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];

  perSystem = { config, pkgs, ... }: {
    overlayAttrs = {
      inherit (config.packages) vacuumtube;
    };
  };

  flake.nixosModules.commonSetup = { pkgs, lib, self', ... }: {
      imports = [
        inputs.nixcord.nixosModules.nixcord
        inputs.home-manager.nixosModules.home-manager
        inputs.agenix.nixosModules.default
      ];

      age = {
        secrets = {
          rclone-ndcfiles = {
            file = ../../secrets/rclone-ndcfiles.age;
            owner = "lily";
            group = "users";
            mode = "770";
          };
        };
      };

      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nixpkgs.overlays = [
        inputs.helium.overlays.default
      ];

      services.resolved.enable = true;

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = { inherit inputs; };
      };

      environment.systemPackages = with pkgs; [
        blanket
        dbeaver-bin
        feishin
        audacity

        # mini tools
        mousam gitte

        # cli tools
        gnumake gcc cmake
        git diffnav
        nushell
        aria2
        wget
        bat
        duf
        dust
        edir
        eza
        fastfetch
        fd ripgrep
        fzf
        yt-dlp
        helix
        inxi
        iotop
        btop
        mpv
        (pkgs.callPackage ../../pkgs/vacuumtube.nix {})
        rclone
        trash-cli playerctl
        tree
        unrar unzip
        jq yq
        wl-clipboard-rs
        inputs.nix-converter.packages.${pkgs.stdenv.hostPlatform.system}.default

        vivaldi vivaldi-ffmpeg-codecs
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
        inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
        helium
        
        voxtype voxtype-vulkan
        netbird
        zoxide
        yazi
        oh-my-posh

        nodejs_26

        python314 python314Packages.requests libb2
        python314Packages.yt-dlp-ejs
        pipx uv

        syncthing

        steam-run
        wine
        winePackages.yabridge

        game-devices-udev-rules
      ];

      services.openssh.enable = true;
      
      services.flatpak.enable = true;

      services.tailscale = {
        enable = true;
        useRoutingFeatures = "both";
        openFirewall = true;
      };

      programs.fish.enable = true;

      programs.localsend = {
        enable = true; openFirewall = true;
      };
  
  };
}
