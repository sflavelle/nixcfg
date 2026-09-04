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

        # cli tools
        git diffnav
        aria2
        wget
        duf
        dust
        edir
        eza
        fastfetch
        fd
        fzf
        yt-dlp
        helix
        inxi
        iotop
        btop
        mpv
        (pkgs.callPackage ../../pkgs/vacuumtube.nix {})
        rclone
        trash-cli
        tree
        unrar unzip
        jq yq
        wl-clipboard-rs

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

      programs.nixcord = {
        enable = true;
        user = "lily";
        discord.vencord.enable = true;

        extraConfig.plugins = {
          userMessagesPronouns = {
            pronounSource = 0;
            showInMessages = true;
            showInProfile = true;
          };
        };

        config = {
          autoUpdate = false;
          notifyAboutUpdates = false;
          disableMinSize = true;
          frameless = true; 
          transparent = true;

          enabledThemeLinks = [
            "https://rdf1337.github.io/DiscordSnippets/VoicePanelNoChevrons/main.css"
            "https://themes.equicord.org/api/22"
            "https://themes.equicord.org/api/63"
            "https://themes.equicord.org/api/23"
            "https://themes.equicord.org/api/9"
            "https://themes.equicord.org/api/67"
          ];
        };
      };
  
  };
}
