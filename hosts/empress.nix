{ config
, pkgs
, lib
, inputs
, ...
}:

{
  hostSpec = {
    hostName = "empress";
    isPublic = true;
    isHandheld = true;
    isAutoStyled = true;
    wallpaper = pkgs.fetchurl {
      url = "https://w.wallhaven.cc/full/o3/wallhaven-o3ylm7.jpg"; # OneShot wallpaper
      hash = "sha256-QMZDE/bQG91o9L47jhJRwpQ3w44DCq1Y4IiuU/B66dw=";

    };
    wirelessInterface = "wlp1s0";
    hasBattery = true;
  };
  monitors = [
    {
      name = "eDP-1";
      primary = true;
      width = 2560;
      height = 1600;
      refreshRate = 60;
      transform = 90;
      scale = 2; # Adjust scale for high DPI displays
    }
  ];

  imports =
    [
      # Include the results of the hardware scan.
      ../hardware/empress.nix
    ];

  services.displayManager.autoLogin.user = config.hostSpec.userName;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;


  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  services.handheld-daemon = {
    enable = true;
    ui.enable = true;
    user = config.hostSpec.userName;
  };
  programs.steam.enable = true;

  # Jovian currently conflicts with Flatpak because of XDG Portals
  # I'll have to figure this out eventually, but for now
  # services.flatpak.enable = lib.mkForce false;

  jovian = {
    steam.enable = true;
    steam.autoStart = true;
    steam.desktopSession = "plasma";
    steam.user = config.hostSpec.userName;
  };

  programs.opengamepadui = {
    enable = true;

  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    maliit-keyboard
    maliit-framework
    kdePackages.qtvirtualkeyboard
    wvkbd
    squeekboard
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
