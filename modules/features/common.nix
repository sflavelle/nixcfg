{ self, inputs, ... }: {

  flake.nixosModules.commonSetup = { config, pkgs, ... }: {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      environment.systemPackages = with pkgs; [
        blanket
        dbeaver-bin
        localsend
        vesktop arrpc

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
        rclone
        trash-cli
        tree
        unrar unzip
        jq yq
        vivaldi vivaldi-ffmpeg-codecs
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
        voxtype
        netbird
        zoxide
        yazi

        python314Packages.yt-dlp-ejs
        pipx

        steam-run
        wine
        winePackages.yabridge
      ];

      services.openssh.enable = true;
      
      services.flatpak.enable = true;

      programs.fish = {
        enable = true;
      };

  };
}
