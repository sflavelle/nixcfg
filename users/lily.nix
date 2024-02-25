{ home-manager, config, pkgs, lib, ...} :

    let
      pywalfox = pkgs.python39.pkgs.buildPythonPackage rec {
	    pname = "pywalfox";
	    version = "2.7.4";
	    doCheck = false;
	    src = pkgs.python39.pkgs.fetchPypi {
	      inherit pname version;
	      sha256 = "0rpdh1k4b37n0gcclr980vz9pw3ihhyy0d0nh3xp959q4xz3vrsr";
	    };
      };

      graphical = config.services.xserver.enable;

    in

{
  home-manager.users.lily = import ./hm-lily.nix;
  users.users.lily = {
    isNormalUser = true;
    description = "Lily Flavelle";
    extraGroups = [ "networkmanager" "wheel" "input" ];
    shell = pkgs.zsh;
    packages = with pkgs; lib.mkMerge [
        ([
	      # Terminal
	      neofetch eza bat btop
	      nnn comodoro kakoune emacs tmux
	      neovim
	      calc edir epr

	      ripgrep jq yq-go yj
	      just fd

	      zoxide oh-my-posh
	      fzf gallery-dl gh khal
	      yt-dlp mpv playerctl
	      mlt sox linuxwave

	      nix-prefetch

	      steam-run

	      pandoc
	 ])
	 (lib.mkIf config.services.xserver.enable [
	      # Programs
	      firefox vivaldi
	      nextcloud-client
	      vscode libreoffice
	      qbittorrent
	      (discord.override {withOpenASAR = true; withVencord = true;}) beeper
	      playerctl mpdris2 ncmpcpp snapcast mpc-cli
	      bitwarden
	      jellyfin-media-player vlc streamlink
	      calibre variety rclone
	      protonup-qt
	      kitty kitty-img kitty-themes

	      pywal pywalfox

         ])
         (lib.mkIf config.services.xserver.desktopManager.gnome.enable [
            gnome.gnome-tweaks gnome.gnome-shell-extensions 
         ])
    ];
  };

  programs.fish.enable = true;

  nixpkgs.config.permittedInsecurePackages = [
  	"pulsar-1.109.0"
  ];


  nix.settings.trusted-users = [ "lily" ];
  security.sudo.wheelNeedsPassword = false;

}
