{ self, inputs, ... }: {

  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];

  perSystem = { config, pkgs, ... }: {
    overlayAttrs = {
      inherit (config.packages) vacuumtube;
    };
  };

  flake.nixosModules.commonSetup = { self, config, pkgs, ... }: {
      imports = [
        inputs.nixcord.nixosModules.nixcord
      ];
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      environment.systemPackages = with pkgs; [
        blanket
        dbeaver-bin
        localsend
        feishin

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
        gallery-dl
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
        vivaldi vivaldi-ffmpeg-codecs
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
        
        voxtype voxtype-vulkan
        netbird
        zoxide
        yazi
        oh-my-posh

        python314Packages.yt-dlp-ejs
        pipx

        syncthing

        steam-run
        wine
        winePackages.yabridge

        game-devices-udev-rules
      ];

      services.openssh.enable = true;
      
      services.flatpak.enable = true;

      programs.fish = {
        enable = true;
      };

      programs.nixcord = {
        enable = true;
        user = "lily";
        discord.equicord.enable = true;

        config = {
          autoUpdate = false;
          notifyAboutUpdates = false;
          disableMinSize = true;
          transparent = true;

          enabledThemeLinks = [
            "https://rdf1337.github.io/DiscordSnippets/VoicePanelNoChevrons/main.css"
            "https://raw.githubusercontent.com/sdhEmily/TranslucentSide/refs/heads/main/TranslucentSide.theme.css"
          ];
        };

        config.plugins = {
          clearUrls.enable = true;
          concatenatedComponentExtractor.enable = true;
          copyEmojiMarkdown.enable = true;
          crashHandler.enable = true;
          dearrow = {
            enable = true;
            dearrowByDefault = false;
          };
          disableDeepLinks.enable = true;
          dontRoundMyTimestamps.enable = true;
          expressionCloner.enable = true;
          fullSearchContext.enable = true;
          greetStickerPicker.enable = true;
          implicitRelationships.enable = true;
          mentionAvatars.enable = true;
          moreUserTags = {
            enable = true;
            tagSettings = {
              webhook = { };
              owner = { };
              administrator = { };
              moderatorStaff = { };
              moderator = { };
              voiceModerator = { };
              chatModerator = { };
            };
          };
          noMaskedUrlPaste.enable = true;
          noTrack.enable = true;
          relationshipNotifier.enable = true;
          replyTimestamp.enable = true;
          sendTimestamps.enable = true;
          settings.enable = true;
          showConnections.enable = true;
          supportHelper.enable = true;
          themeAttributes.enable = true;
          typingIndicator.enable = true;
          unindent.enable = true;
          userMessagesPronouns.enable = true;
          validReply.enable = true;
          validUser.enable = true;
          viewIcons.enable = true;
          voiceMessages.enable = true;
          volumeBooster.enable = true;
          webContextMenus = {
            enable = true;
            addBack = true;
          };
          webKeybinds.enable = true;
          webScreenShareFixes.enable = true;
        };
      extraConfig.plugins = {
        platformIndicators = {
          badges = true;
        };
        userMessagesPronouns = {
          pronounSource = 0;
          showInMessages = true;
          showInProfile = true;
        };
      };
    };
  };
}
