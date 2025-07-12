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

    agenix.url = "github:ryantm/agenix";

    audio = {
      url = "github:polygon/audio.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri.url = "github:sodiboo/niri-flake";
    ignis.url = "github:ignis-sh/ignis";
    ignis.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixgl.url = "github:nix-community/nixGL";
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

    pre-commit-hooks.url = "github:cachix/git-hooks.nix";

  };

  outputs =
    { self
    , nixpkgs
    , nix-stable
    , nixos-hardware
    , nixos-generators
    , ...
    }@inputs:
    let
      inherit (self) outputs;
      inherit (nixpkgs) lib;

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
          inherit inputs outputs;
          system = "x86_64-linux";
          nixgl = inputs.nixgl;
          nixpkgs = inputs.nixpkgs;
        };
      };

      checks.${system}.pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          nixpkgs-fmt.enable = true;
        };
      };

      devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
      };

      overlays =
        rec {
          default = sfpkgs;
          sfpkgs = final: prev: import ./overlay.nix final prev;
        }

          nixosModules."commonModules" = import ./modules/common.nix;
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

            ./modules/desktop-prod-audio.nix
            ./modules/desktop-prod-video.nix
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
            inputs.jovian.nixosModules.default

            ./hosts/minion.nix
            ./modules/wifi-home.nix
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
            ./modules/wifi-home.nix
            ./modules/users/lily

            #             ./modules/desktop-games.nix
            ./modules/desktop-software.nix

            ./modules/desktop-prod-audio.nix
            ./modules/desktop-prod-video.nix
            ./modules/dev.nix

            ./modules/chat.nix

            {
              nix.settings = {
                extra-substituters = [ "https://cache.soopy.moe" ];
                extra-trusted-public-keys = [ "cache.soopy.moe-1:0RZVsQeR+GOh0VQI9rvnHz55nVXkFardDqfm4+afjPo=" ];
              };
            }
          ];
        };
        "dweller" = nixpkgs.lib.nixosSystem {
          # Acer Chromebook C720
          system = system;
          specialArgs = { inherit inputs outputs; };
          modules = [
            self.nixosModules.commonModules

            ./hosts/dweller.nix
            ./modules/wifi-home.nix
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
            ./modules/wifi-home.nix
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
    };
}
