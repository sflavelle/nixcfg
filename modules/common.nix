{ self
, config
, lib
, pkgs
, inputs
, outputs
, system
, ...
}:
{
  imports = [
    inputs.nixos-generators.nixosModules.all-formats
    inputs.home-manager.nixosModules.home-manager
    inputs.niri.nixosModules.niri
    inputs.stylix.nixosModules.stylix
    inputs.agenix.nixosModules.default

    ./modules/age.nix
    ./modules/options
    # ./secrets/secrets.nix
  ];

  virtualisation.diskSize = 32 * 1024;

  programs.fish.enable = true;
  programs.kdeconnect.enable = !config.hostSpec.isServer;

  services.openssh.enable = true;
  services.tailscale.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      hinfo = true;
      domain = true;
    };
  };
  services.speechd.enable = true;

  services.displayManager.gdm.enable = !config.hostSpec.isServer && !config ? jovian.steam.autoStart;
  programs.niri.enable = !config.hostSpec.isServer;
  programs.niri.package = pkgs.niri-unstable;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  users.defaultUserShell = pkgs.fish;
  security.sudo.wheelNeedsPassword = lib.mkDefault false;

  programs.nix-index.enable = true;
  programs.command-not-found.enable = lib.mkForce false;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs outputs; };
    sharedModules = lib.mkMerge [
      [
        inputs.agenix.homeManagerModules.default
        ./modules/programs/mpv-watch.nix
      ]
      (lib.mkIf (!config.hostSpec.isAutoStyled)
        [ inputs.stylix.homeModules.stylix ]
      )
    ];
  };

  environment.pathsToLink = [ "/share/xdg-desktop-portal" "/share/applications" ];

  environment.systemPackages = lib.mkMerge [
    (with pkgs; [
      duf
      dust
      fd
      eza
      curl
      wget
      unzip
      fzf
      btop
      psmisc
      pciutils
      blueman
      bluetui
      pied
      piper-tts

      helix
      oh-my-posh
      zellij
      cameractrls

      wl-clipboard-rs

      nvd
      nix-output-monitor
      nixfmt-rfc-style
    ])
    (with pkgs; lib.mkIf config.services.desktopManager.gnome.enable [
      gnomeExtensions.tweaks-in-system-menu
      gnome-tweaks
    ])
    # (lib.mkIf config.programs.niri.enable [ inputs.xwayland-satellite.packages.${system}.xwayland-satellite ])
  ];
  environment.variables = {
    EDITOR = "hx";
  };

  nixpkgs = {
    overlays = [ overlay-stable inputs.niri.overlays.niri inputs.audio.overlays.default ];
    config.allowUnfree = true;
    config.permittedInsecurePackages = permittedInsecurePackages;
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ config.hostSpec.userName ];
    substituters = [ "https://watersucks.cachix.org" "https://ezkea.cachix.org" ];
    trusted-public-keys = [
      "watersucks.cachix.org-1:6gadPC5R8iLWQ3EUtfu3GFrVY7X6I4Fwz/ihW25Jbv8="
      "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
    ];
  };
  # system.rebuild.enableNg = true; # enable the new NixOS rebuild system

}
