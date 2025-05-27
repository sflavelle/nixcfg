{
  description = "Splatsune's NixOS Flake Experiments";

  # This is the standard format for flake.nix.
  # `inputs` are the dependencies of the flake,
  # and `outputs` function will return all the build results of the flake.
  # Each item in `inputs` will be passed as a parameter to
  # the `outputs` function after being pulled and built.
  inputs = {
    # There are many ways to reference flake inputs.
    # The most widely used is `github:owner/name/reference`,
    # which represents the GitHub repository URL + branch/commit-id/tag.

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
    nixos-cli.url = "github:nix-community/nixos-cli";

    erosanix.url = "github:emmanuelrosa/erosanix"; # mkWindowsApp

    niri.url = "github:sodiboo/niri-flake";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixgl.url   = "github:nix-community/nixGL";
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-brcm-fw = {
      url = "github:AdityaGarg8/Apple-Firmware";
      flake = false;
    };
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      nix-stable,
      nixos-hardware,
      nixos-generators,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";

      permittedInsecurePackages = [
      ];

      overlay-stable = final: prev: {
        stable = import nix-stable {
          inherit system;
          config.allowUnfree = true;
          config.permittedInsecurePackages = permittedInsecurePackages;
        };
      };
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.permittedInsecurePackages = permittedInsecurePackages;
      };
    in
    {
      homeConfigurations.lily = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          modules/users/lily/home.nix
          inputs.niri.homeModules.niri
          ];
        extraSpecialArgs = {
          inherit inputs;
          nixgl = inputs.nixgl;
          nixpkgs = inputs.nixpkgs;
        };
      };
      nixosModules."commonModules" =
        {
          config,
          lib,
          pkgs,
          inputs,
          system,
          ...
        }:
        {
          imports = [
            inputs.nixos-generators.nixosModules.all-formats
            inputs.home-manager.nixosModules.home-manager
            inputs.niri.nixosModules.niri
            inputs.nixos-cli.nixosModules.nixos-cli
            
            ./modules/options
          ];

          virtualisation.diskSize = 6 * 1024;

          programs.fish.enable = true;
          programs.kdeconnect.enable = !config.hostSpec.isServer;

          services.openssh.enable = true;
          services.tailscale.enable = true;
          services.avahi.enable = true;
          services.avahi.nssmdns4 = true;

          services.displayManager.sddm.enable = !config.hostSpec.isServer && !config ? jovian.steam.autoStart;
          services.desktopManager.plasma6.enable = !config.hostSpec.isServer;
          programs.niri.enable = !config.hostSpec.isServer;
          programs.niri.package = pkgs.niri-unstable;

          users.defaultUserShell = pkgs.fish;
          security.sudo.wheelNeedsPassword = lib.mkDefault false;

          programs.nix-index.enable = true;
          programs.command-not-found.enable = lib.mkForce false;

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs; };
            sharedModules = [
              inputs.plasma-manager.homeManagerModules.plasma-manager
              # inputs.niri.homeModules.niri
            ];
          };

          environment.systemPackages = lib.mkMerge [
            (with pkgs; [
                duf dust fd eza
                curl wget
                fzf
                btop
                helix
                oh-my-posh
                zellij

                nvd nix-output-monitor
            ])
            (with pkgs; lib.mkIf config.services.xserver.desktopManager.gnome.enable [
                gnomeExtensions.tweaks-in-system-menu
                gnome-tweaks
            ])
          ];
          environment.variables = {
            EDITOR = "hx";
          };

          nixpkgs.overlays = [ overlay-stable inputs.niri.overlays.niri ];
          nixpkgs.config.allowUnfree = true;

          nix.settings = {
            experimental-features = [
              "nix-command"
              "flakes"
            ];
            trusted-users = [ config.hostSpec.userName ];
            substituters = [ "https://watersucks.cachix.org" ];
            trusted-public-keys = [
              "watersucks.cachix.org-1:6gadPC5R8iLWQ3EUtfu3GFrVY7X6I4Fwz/ihW25Jbv8="
            ];
          };

          services.nixos-cli = {
            enable = true;
            prebuildOptionCache = config.hostSpec.hostName == "snatcher"; # build option index on main pc
            config = {
              use_nvd = true;

              apply.use_nom = true;
            };
          };

          services.gnome = lib.mkIf config.services.xserver.desktopManager.gnome.enable {
            gnome-browser-connector.enable = true;
          };

        };
      nixosConfigurations = {
        "snatcher" = nixpkgs.lib.nixosSystem {
          # Primary Desktop PC
          system = system;
          specialArgs = { inherit inputs; };
          modules = [
            self.nixosModules.commonModules
            ./hosts/snatcher.nix
            ./hardware/snatcher.nix
            ./modules/mounts-snatcher.nix
            ./modules/users/lily


            ./modules/desktop-games.nix
            ./modules/desktop-vr.nix
            ./modules/desktop-software.nix
            ./modules/dev.nix
            ./modules/chat.nix
          ];
        };
        "minion" = nixpkgs.lib.nixosSystem {
          # Infinity Gaming laptop
          system = system;
          specialArgs = { inherit inputs; };
          modules = [
            self.nixosModules.commonModules
            ./hosts/minion.nix
            ./modules/users/lily
            ./modules/desktop-games.nix
            ./modules/desktop-software.nix
            ./modules/dev.nix
            ./modules/chat.nix
          ];
        };
        "badgeseller" = nixpkgs.lib.nixosSystem {
          # Apple MacBook Air (2019)
          system = system;
          specialArgs = { inherit inputs; };
          modules = [
            self.nixosModules.commonModules
            inputs.nixos-hardware.nixosModules.apple-t2
            inputs.disko.nixosModules.disko
            ./modules/disko/badgeseller.nix

            ./hosts/badgeseller.nix
            ./modules/users/lily
#             ./modules/desktop-games.nix
            ./modules/desktop-software.nix
            ./modules/dev.nix
            ./modules/chat.nix
          ];
        };
        "dweller" = nixpkgs.lib.nixosSystem {
          # Acer Chromebook C720
          system = system;
          specialArgs = { inherit inputs; };
          modules = [
            self.nixosModules.commonModules

            ./hosts/dweller.nix
            ./modules/users/lily
            ./modules/chromebook.nix
            ./modules/dev.nix
            ./modules/chat.nix

            # inputs.disko.nixosModules.disko
            # ./modules/disko/dweller.nix
          ];
        };
        "empress" = nixpkgs.lib.nixosSystem {
          # Lenovo Legion Go
          system = system;
          specialArgs = { inherit inputs; };
          modules = [
            self.nixosModules.commonModules
            inputs.jovian.nixosModules.default

            ./hosts/empress.nix
            ./modules/users/lily
            ./modules/desktop-games.nix
            ./modules/desktop-software.nix
            ./modules/chat.nix
          ];
        };

        # Servers
        "puppetmaster" = nixpkgs.lib.nixosSystem {
          # Home Lab
          system = system;
          specialArgs = { inherit inputs; };
          modules = [
            self.nixosModules.commonModules
            ./hosts/puppetmaster.nix
            inputs.disko.nixosModules.disko
            ./modules/disko/puppetmaster.nix
            ./modules/users/lily
            ./modules/users/juno

            ./modules/home-audio.nix
            ./modules/snapclient.nix
            ./modules/srv-arr.nix
          ];
        };
        "ndc" = nixpkgs.lib.nixosSystem {
          # Neurario.com VPS
          system = system;
          specialArgs = { inherit inputs; };
          modules = [
            self.nixosModules.commonModules
            ./hosts/neurariodotcom.nix
            ./modules/users/lily

            ./modules/dev.nix
          ];
        };
      };
      packages.x86_64-linux = {
        link-steamscreenshots = pkgs.callPackage ./pkgs/link-steamscreenshots {};
      };
    };
}
