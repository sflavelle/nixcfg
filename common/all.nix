{ config, lib, pkgs, ... }:

{

  boot.kernelPackages = lib.mkDefault pkgs.linuxKernel.packages.linux_6_7;
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
  };
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  # Enable networking
  networking.networkmanager.enable = lib.mkDefault true;
  networking.search = [ "local" ];

  # Set your time zone.
  time.timeZone = "Australia/Melbourne";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  environment.systemPackages = with pkgs; [
    distrobox
    rclone
    pciutils
    inxi
    du-dust

    zip
    xz
    unzip
    p7zip
    rar
    unrar
    sops

    nvd
  ];

  programs.nix-ld.enable = true;
  programs.zsh.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };

  programs.mosh = {
    enable = true;
    openFirewall = true;
  };

  services.zerotierone = {
    enable = true;
    joinNetworks = [ "e4da7455b2e8404f" ];
  };

  programs = {
    fzf = {
      keybindings = true;
      fuzzyCompletion = true;
    };

  };

  stylix.image = ../resources/wallpapers/Distance-AllianceOS.png; # Boot/Login Theme
  
  environment.shellAliases = {
      just-nix = "just -f ${ pkgs.fetchurl { url = "https://git.neurario.com/splatsune/nixcfg/raw/commit/b6ceae769a15556313bb56d279c70459d3c89a39/justfile"; hash = "sha256-6yeRLYYVcjWMnU6U5JNpoNb0cmx4TknPJO2ht34vZvo="; } }";
  };
}
