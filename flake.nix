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

    erosanix.url = "github:emmanuelrosa/erosanix"; # mkWindowsApp
    audio = {
      url = "github:polygon/audio.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri.url = "github:sodiboo/niri-flake";
    ignis.url = "github:ignis-sh/ignis";
    ignis.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixgl.url   = "github:nix-community/nixGL";
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    aagl.url = "github:ezKEa/aagl-gtk-on-nix";
    aagl.inputs.nixpkgs.follows = "nixpkgs";

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
        "freeimage-3.18.0-unstable-2024-04-18"
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
          # inputs.niri.homeModules.niri
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
            inputs.stylix.nixosModules.stylix

            ./modules/options
          ];

          virtualisation.diskSize = 32 * 1024;

          programs.fish.enable = true;
          programs.kdeconnect.enable = !config.hostSpec.isServer;

          services.openssh.enable = true;
          services.tailscale.enable = true;
          services.avahi.enable = true;
          services.avahi.nssmdns4 = true;

          services.xserver.displayManager.lightdm.enable = !config.hostSpec.isServer && !config ? jovian.steam.autoStart;
          services.xserver.displayManager.lightdm.greeters.gtk.enable = true;
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
            extraSpecialArgs = { inherit inputs; };
            sharedModules = [
              # inputs.stylix.homeModules.stylix
            ];
          };

          environment.pathsToLink = [ "/share/xdg-desktop-portal" "/share/applications" ];

          environment.systemPackages = lib.mkMerge [
            (with pkgs; [
                duf dust fd eza
                curl wget unzip
                fzf 
                btop psmisc

                helix
                oh-my-posh
                zellij
                cameractrls

                wl-clipboard-rs

                nvd nix-output-monitor
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

        };
      nixosConfigurations = {
        "snatcher" = nixpkgs.lib.nixosSystem {
          # Primary Desktop PC
          system = system;
          specialArgs = { inherit inputs outputs; };
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
          specialArgs = { inherit inputs outputs; };
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
          specialArgs = { inherit inputs outputs; };
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
          specialArgs = { inherit inputs outputs; };
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
          specialArgs = { inherit inputs outputs; };
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
          specialArgs = { inherit inputs outputs; };
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
          specialArgs = { inherit inputs outputs; };
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
        ableton-live = pkgs.callPackage ./pkgs/ableton.nix {
          inherit (inputs.erosanix.lib.${system}) mkWindowsAppNoCC copyDesktopIcons makeDesktopIcon;
          wine = pkgs.wine64Packages.stagingFull;
          # wineArch = "win64";
        };
        vacuumtube = pkgs.callPackage ./pkgs/vacuumtube.nix { };

        # Fonts
        otf-determination = pkgs.callPackage ./pkgs/fonts/otf-determination.nix {};
        ttf-utpapyrus = pkgs.callPackage ./pkgs/fonts/ttf-utpapsans.nix { fontVariant = "Papyrus"; };
        ttf-utsans = pkgs.callPackage ./pkgs/fonts/ttf-utpapsans.nix { fontVariant = "Sans"; };
      };
    };
}
