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
        ([
          # Terminal
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
        (lib.mkIf config.services.xserver.enable [
          # Programs
          vscode
          (discord.override {
            withOpenASAR = !lowPower;
            withVencord = !lowPower;
          })
          playerctl
          bitwarden
          (if !lowPower then jellyfin-media-player else jellyfin-mpv-shim)
          rclone

        ])
        (lib.mkIf config.services.xserver.enable && !lowPower [
            libreoffice
            calibre
            protonup-qt
            steam-run
        ])
        (lib.mkIf config.services.xserver.desktopManager.gnome.enable [
          gnome.gnome-tweaks
          gnome.gnome-shell-extensions
        ])
      ];
  };

  nix.settings.trusted-users = [ "lily" ];
  security.sudo.wheelNeedsPassword = false;

}
