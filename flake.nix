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

  };

  outputs =
    { self,
      nixpkgs,
      nix-stable,
      nixos-hardware,
      nixos-generators,
      ... }@inputs:
	let
	  system = "x86_64-linux";
	  overlay-stable = final: prev: {
            stable = import nix-stable { inherit system; config.allowUnfree = true; };
	  };
	in
      {
      nixosModules."commonModules" = { config, lib, inputs, ... }:{
        imports = [
        ];

        nixpkgs.overlays = [ overlay-stable ];

        nix.settings = {
          substituters = [];
          trusted-public-keys = [];
        };
	nixpkgs.config.permittedInsecurePackages = [
        ];
      };
      nixosConfigurations = {
        "snatcher" = nixpkgs.lib.nixosSystem {
          # Primary Desktop PC
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/snatcher.nix
            self.nixosModules.commonModules
          ];
        };
        "minion" = nixpkgs.lib.nixosSystem {
          # Infinity Gaming laptop
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/minion.nix
            self.nixosModules.commonModules

          ];
        };
        "empress" = nixpkgs.lib.nixosSystem {
	  # Lenovo Legion Go
	  system = "x86_64-linux";
	  specialArgs = { inherit inputs; };
	  modules = [
	    ./hosts/empress.nix
	    self.nixosModules.commonModules
	    inputs.jovian.nixosModules.default
	  ];
        };
        "dweller" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/dweller.nix
            self.nixosModules.commonModules
          ];
        };
        "badgeseller" = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit inputs; };
            modules = [
                ./hosts/badgeseller.nix
                self.nixosModules.commonModules
                nixos-hardware.nixosModules.apple-macbook-air-6
                nixos-hardware.nixosModules.apple-t2
            ];
        };
        "rumbi" = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit inputs; };
            modules = [
                # This is just meant to be used as a Home Assistant terminal basically
                # We'll put what we need to run web and media stuff

                self.nixosModules.commonModules
                ./hosts/rumbi.nix
            ];
        };
    };
}
