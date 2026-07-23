{ self, inputs, ... }: {

  flake.nixosModules.commonSetup = { config, pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        blanket
        dbeaver-bin
        localsend
        vesktop arrpc

        # cli tools
        git
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
        unrar
        vivaldi vivaldi-ffmpeg-codecs
        voxtype
        netbird
        zoxide
        yazi

        python314Packages.yt-dlp-ejs
      ];

      services.openssh.enable = true;

  };
}
