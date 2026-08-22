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
        inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
        helium
        
        voxtype voxtype-vulkan
        netbird
        zoxide
        yazi
        oh-my-posh

        nodejs_26

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
        discord.equicord.enable = true;

        extraConfig.plugins = {
          fontLoader = {
            applyOnClodeBlocks = false;
          };
          globalBadges = {
            showRa1ncord = true;
          };
          musicRichPresence = {
            showLastFmLogo = true;
          };
          noBlockedMessages = {
            ignoreBlockedMessages = false;
          };
          richPresence = {
            _migrated = true;
          };
          translate = {
            shavian = true;
            sitelen = true;
            target = "en";
            toki = true;
          };
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

          plugins = {
            accountPanelServerProfile.enable = true;
            animalese.enable = true;
            betterAudioPlayer.enable = true;
            channelTabs = {
              showBookmarkBar = false;
            };
            clearUrls.enable = true;
            collapsibleUi = {
              enable = true;
              headerBarCollapsed = true;
            };
            commandPalette = {
              enable = true;
              hotkey = [ "ctrl" "/" ];
            };
            concatenatedComponentExtractor.enable = true;
            concatenatedModules.enable = true;
            copyEmojiMarkdown.enable = true;
            crashHandler.enable = true;
            customTimestamps = {
              formats = {
                enable = false;
              };
            };
            dearrow = {
              enable = true;
              dearrowByDefault = false;
            };
            declutter = {
              enable = true;
              removeFamilyCenterAboveDms = true;
              removeQuestsAboveDms = true;
              removeShopAboveDms = true;
            };
            disableDeepLinks.enable = true;
            dontRoundMyTimestamps.enable = true;
            dragify = {
              enable = true;
              reuseExistingInvites = true;
            };
            expressionCloner.enable = true;
            friendshipRanks.enable = true;
            fullSearchContext.enable = true;
            fullVcpfp.enable = true;
            gifCollections.enable = true;
            gifMaker.enable = true;
            greetStickerPicker.enable = true;
            homeTyping.enable = true;
            implicitRelationships.enable = true;
            lastActive.enable = true;
            markdownTables.enable = true;
            mentionAvatars.enable = true;
            messageBurst.enable = true;
            moreUserTags = {
              enable = true;
              tagSettings = {
                administrator = {
                  enable = false;
                };
                chatModerator = {
                  enable = false;
                };
                moderator = {
                  enable = false;
                };
                moderatorStaff = {
                  enable = false;
                };
                owner = {
                  enable = false;
                };
                voiceModerator = {
                  enable = false;
                };
                webhook = {
                  enable = false;
                };
                enable = false;
              };
            };
            noMaskedUrlPaste.enable = true;
            noTrack.enable = true;
            openInApp.enable = true;
            randomVoice = {
              keybind = [ ];
            };
            relationshipNotifier.enable = true;
            replyTimestamp.enable = true;
            richPresence = {
              enable = true;
              ndAlbumArtMode = "instance";
              ndEnabled = true;
              ndNameString = "{artist}";
              ndPassword = "M33p...";
              ndServerUrl = "https://lib.neurario.com";
              ndUsername = "Splatsune";
            };
            sedEnhanced.enable = true;
            sendTimestamps.enable = true;
            settings.enable = true;
            showConnections.enable = true;
            sidebarChat.enable = true;
            statusPresets.enable = true;
            summaries.enable = true;
            supportHelper.enable = true;
            themeAttributes.enable = true;
            themeLibrary = {
              enable = true;
              hideWarningCard = true;
            };
            timezones = {
              enable = true;
              askedTimezone = true;
            };
            toneIndicators.enable = true;
            typingIndicator.enable = true;
            unindent.enable = true;
            userMessagesPronouns.enable = true;
            validReply.enable = true;
            validUser.enable = true;
            vcNarrator = {
              voice = null;
            };
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
        };
      };
  
  };
}
