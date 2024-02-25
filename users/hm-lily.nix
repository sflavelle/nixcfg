{ osConfig, lib, pkgs, ... }:
    let
    	host = osConfig.networking.hostName;
    	graphical = osConfig.services.xserver.enable;
    in
{
    home = {
        username = "lily";
        homeDirectory = "/home/lily";
	stateVersion = "23.11";
        sessionPath = [];
        sessionVariables = {
            MPD_HOST = "10.0.0.3";
            EDITOR = "kak";
        };
        shellAliases = {};
    };

    stylix = {
        autoEnable = graphical;
        image = if host == "snatcher" then
        	/home/lily/Pictures/gallery-dl/tumblr/tumblr_xing2lee_121027387230_02.jpg
        	else if host == "minion" then
        	/home/lily/Pictures/Wallpapers/Windows/img0_3840x2160.jpg
        	else
        	/home/lily/Pictures/Wallpapers/gallery-dl/wallhaven/wallhaven_j3d79p_3440x1440.jpg;
	fonts = rec {
		monospace = {
			name = "Fira Code";
			package = pkgs.fira-code;
		};
		sansSerif = {
			name = "Cantarell";
			package = pkgs.cantarell-fonts;
		};
		serif = sansSerif;
	};
    };

    programs.bat.enable = true;
    programs.btop.enable = true;
    programs.comodoro.enable = true;
    programs.eza = {
        enable = true;
	enableAliases = true;
	icons = true;
    };
    programs.feh.enable = graphical;
    programs.firefox = {
        enable = graphical;
    };
    programs.fzf.enable = true;
    programs.gallery-dl.enable = true;
    programs.gh.enable = true;
    programs.kakoune.enable = true;
    programs.khal.enable = true;
    programs.mangohud.enable = graphical;
    programs.mangohud.enableSessionWide = true;
    programs.mangohud.settings = {
	  output_folder = /home/lily/Documents/mangohud;
	  full = true;
    };
    programs.mpv = {
        enable = graphical;
    };
    programs.obs-studio = {
        enable = graphical;
        plugins = with pkgs.obs-studio-plugins; [
		obs-vkcapture input-overlay obs-text-pthread obs-source-clone
		obs-shaderfilter obs-source-record obs-pipewire-audio-capture
        ];
    };
    programs.pandoc.enable = true;
    programs.pywal.enable = true;
    programs.yt-dlp.enable = true;

    programs.git = {
       enable = true;
       userName = "Lily Flavelle";
       userEmail = "me@neurario.com";
   };

    qt.enable = graphical;

    services.darkman = {
        enable = true;
	settings = {
		lat = 36.76;
		lng = 144.29;
		usegeoclue = true;
	};
        darkModeScripts = {};
        lightModeScripts = {};
    };

    services.playerctld.enable = true;
}
