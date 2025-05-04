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
    niri.url = "github:sodiboo/niri-flake";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
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
      overlay-stable = final: prev: {
        stable = import nix-stable {
          inherit system;
          config.allowUnfree = true;
        };
      };
      lib = nixpkgs.lib.extend (self: super: { custom = import ./lib { inherit (nixpkgs) lib; }; });
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations.lily = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ modules/users/lily/home.nix ];
        extraSpecialArgs = { inherit inputs; };
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
            ./modules/options
          ];

          virtualisation.diskSize = 32 * 1024;

          programs.fish.enable = true;

          services.openssh.enable = true;
          services.tailscale.enable = true;
          services.avahi.enable = true;
          services.avahi.nssmdns4 = true;

          services.displayManager.ly.enable = config.hostSpec.isMinimal && !config.hostSpec.isServer;
          services.displayManager.sddm.enable = !config.hostSpec.isMinimal && !config.hostSpec.isHandheld && !config.hostSpec.isServer;
          services.desktopManager.plasma6.enable = !config.hostSpec.isMinimal && !config.hostSpec.isHandheld && !config.hostSpec.isServer;

          users.defaultUserShell = pkgs.fish;
          security.sudo.wheelNeedsPassword = lib.mkDefault false;

          programs.nix-index.enable = true;
          programs.command-not-found.enable = lib.mkForce false;

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs; };
          };

          environment.systemPackages = with pkgs; [
            duf
            dust
            fd
            eza
            curl
            fzf
            btop
            helix
            oh-my-posh
            zellij
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
          };
          nixpkgs.config.permittedInsecurePackages = [
          ];

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
            ./modules/users/lily
            ./modules/desktop-games.nix
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

            inputs.disko.nixosModules.disko
            ./modules/disko-dweller.nix
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
            ./modules/disko-puppetmaster.nix
            ./modules/users/lily
            ./modules/users/juno

            ./modules/home-audio.nix
          ];
        };
      };
      packages."x86_64-linux" = {
        mpv-watch = import ./pkgs/mpv-watch.nix;
        pydymenu = import ./pkgs/pydymenu.nix { };
      };
    };
}
