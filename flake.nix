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
    zen-browser.url = "github:MarceColl/zen-browser-flake";
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
      system = "x86_64-linux";
      overlay-stable = final: prev: {
        stable = import nix-stable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in
    {
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
          ];

          services.openssh.enable = true;
          services.tailscale.enable = true;
          environment.systemPackages = with pkgs; [
            duf dust fd eza curl fzf btop
          ];

          nixpkgs.overlays = [ overlay-stable ];

          nix.settings = {
            experimental-features = [
              "nix-command"
              "flakes"
            ];
            substituters = [ ];
            trusted-public-keys = [ ];
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
            ./modules/desktop-games.nix
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
            ./modules/desktop-games.nix
            ./modules/dev.nix
            ./modules/chat.nix
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
            ./modules/desktop-games.nix
            ./modules/chat.nix
          ];
        };

        # Servers
        "puppetmaster" = nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/puppetmaster.nix
            inputs.disko.nixosModules.disko
            ./modules/disko-puppetmaster.nix
          ];
        };
      };
    };
    packages = {
      mpv-watch = import ./pkgs/mpv-watch.nix;
      pydymenu = import ./pkgs/pydymenu.nix { inherit nixpkgs; };
    };
}
