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
    nix-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    disko = {
        url = "github:nix-community/disko";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
        url = "github:nix-community/nixos-generators";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix.url = "github:musnix/musnix";
    stylix.url = "github:danth/stylix";
    sops-nix.url = "github:Mic92/sops-nix";
    bizhawk.url = "github:TASEmulators/BizHawk/master";
    bizhawk.flake = false;
    mac-brcm-fw = {
        url = "github:AdityaGarg8/Apple-Firmware";
        flake = false;
    };

  };

  outputs =
    { self,
      nixpkgs,
      nix-stable,
      nixos-hardware,
      disko,
      nixos-generators,
      musnix,
      home-manager,
      mac-brcm-fw,
      stylix,
      sops-nix,
      bizhawk,
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
          inputs.home-manager.nixosModules.home-manager
          inputs.stylix.nixosModules.stylix
          inputs.sops-nix.nixosModules.sops
        ];

        nixpkgs.overlays = [ overlay-stable ];

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { inherit inputs; };
        };

        sops = {
          defaultSopsFile = ./secrets/secrets.yaml;
          age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
          age.keyFile = "/home/lily/.config/sops/age/keys.txt";
          age.generateKey = true;
        };

        nix.settings = {
          substituters = [];
          trusted-public-keys = [];
        };
				nixpkgs.config.permittedInsecurePackages = [
                "openssl-1.1.1w"
        ];
      };
      nixosConfigurations = {
        "snatcher" = nixpkgs.lib.nixosSystem {
          # Primary Desktop PC
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          }; # pass custom arguments into all sub module.
          modules = [
            ./hosts/snatcher.nix
            ./common/desktop.nix
            ./users/lily.nix
            musnix.nixosModules.musnix
            self.nixosModules.commonModules
          ];
        };
        "minion" = nixpkgs.lib.nixosSystem {
          # Infinity Gaming laptop
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/minion.nix
            ./common/desktop.nix
            ./users/lily.nix
            self.nixosModules.commonModules

          ];
        };
        "dweller" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/dweller.nix
            ./common/desktop.nix
            ./users/lily.nix
            self.nixosModules.commonModules

            disko.nixosModules.disko
            ./fragments/dweller-disk.nix
          ];
        };
        "badgeseller" = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit inputs; };
            modules = [
                ./hosts/badgeseller.nix
                ./common/desktop.nix
                ./users/lily.nix
                self.nixosModules.commonModules
                nixos-hardware.nixosModules.apple-macbook-air-6
                nixos-hardware.nixosModules.apple-t2

                disko.nixosModules.disko
                ./fragments/badgeseller-disk.nix
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
        # Servers
        "neurariodotcom" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/neurariodotcom.nix
            ./common/server.nix
            ./users/lily.nix
            self.nixosModules.commonModules
          ];
        };
        "conductor" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/conductor.nix
            ./common/server.nix
            ./users/lily.nix
            self.nixosModules.commonModules
          ];
        };
      };
      packages.x86_64-linux = {
        # Utilities
        "isopadre" = nixos-generators.nixosGenerate { # Generic ISO image
        	system = "x86_64-linux";
        	specialArgs = { inherit inputs; };
        	format = "install-iso";
        	modules = [
            	./common/desktop.nix
            	./users/lily.nix
            	self.nixosModules.commonModules
            	{
                	networking.networkmanager.enable = false;
            	}
        	];
      	};
      };
    };
}
