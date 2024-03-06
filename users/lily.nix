{ home-manager, config, pkgs, lib, ... }:

let

  graphical = config.services.xserver.enable;

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

          steam-run

          pandoc
        ])
        (lib.mkIf config.services.xserver.enable [
          # Programs
          vscode
          libreoffice
          qbittorrent
          (discord.override {
            withOpenASAR = true;
            withVencord = true;
          })
          playerctl
          snapcast
          bitwarden
          jellyfin-media-player
          calibre
          rclone
          protonup-qt

        ])
        (lib.mkIf config.services.xserver.desktopManager.gnome.enable [
          gnome.gnome-tweaks
          gnome.gnome-shell-extensions
        ])
      ];
  };

  nixpkgs.config.permittedInsecurePackages = [ "pulsar-1.109.0" ];

  nix.settings.trusted-users = [ "lily" ];
  security.sudo.wheelNeedsPassword = false;

}
