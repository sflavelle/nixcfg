{ home-manager, config, pkgs, lib, ... }:

let

  graphical = config.services.xserver.enable;
  lowPower = config.networking.hostName == "dweller";

in {
  home-manager.users.lily = import ./hm-lily.nix;
  users.users.lily = {
    isNormalUser = true;
    description = "Lily Flavelle";
    extraGroups = [ "networkmanager" "wheel" "input" "audio" "video" ];
    shell = pkgs.zsh;
    packages = with pkgs;
      lib.mkMerge [
        ([ # All systems (terminal)
          neofetch
          emacs
          zellij
          calc
          edir
          epr

          just

          gallery-dl
          yt-dlp
          mpv
          playerctl
          mlt
          sox
          linuxwave

          nix-prefetch

          pandoc
        ])
        (lib.mkIf config.services.xserver.enable [ # All systems (graphical)
          # Programs
          vscode
          (discord.override {
            withOpenASAR = !lowPower;
            withVencord = !lowPower;
          })
          playerctl
          bitwarden
          rclone

        ])
        (lib.mkIf config.services.xserver.enable && !lowPower [ # More powerful devices
            libreoffice
            calibre
            protonup-qt
            steam-run
            jellyfin-media-player
        ])
        (lib.mkIf config.services.xserver.enable && lowPower [ # Less powerful, chromebooks etc)
            jellyfin-mpv-shim
        ])
        (lib.mkIf config.services.xserver.desktopManager.gnome.enable [ # Gnome-specific
          gnome.gnome-tweaks
          gnome.gnome-shell-extensions
        ])
      ];
  };

  nix.settings.trusted-users = [ "lily" ];
  security.sudo.wheelNeedsPassword = false;

}
