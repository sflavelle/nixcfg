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
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    musnix.url = "github:musnix/musnix";
    hyprland.url = "github:hyprwm/Hyprland";
    stylix.url = "github:danth/stylix";
    sops-nix.url = "github:Mic92/sops-nix";

    # Hyprland Plugins
    split-monitor-workspaces = {
        url = "github:Duckonaut/split-monitor-workspaces";
        inputs.hyprland.follows = "hyprland";
    };
  };

  outputs =
    { self,
      nixpkgs,
      musnix,
      home-manager,
      hyprland,
      stylix,
      sops-nix,
      split-monitor-workspaces,
      ... }@inputs: {
      nixosModules."commonModules" = { config, lib, inputs, ... }: {
        imports = [
          inputs.home-manager.nixosModules.home-manager
          inputs.stylix.nixosModules.stylix
          inputs.sops-nix.nixosModules.sops
        ];

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
        };

        sops = {
          defaultSopsFile = ./secrets/secrets.yaml;
          age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
          age.keyFile = "/home/lily/.config/sops/age/keys.txt";
          age.generateKey = true;
        };

				  nix.settings = {
    				substituters = ["https://hyprland.cachix.org"];
    				trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
				  };
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
            {
              sops.secrets = {
                lat = {
                  sopsFile = ./secrets/hass.yaml;
                  owner = "hass";
                };
                long = {
                  sopsFile = ./secrets/hass.yaml;
                  owner = "hass";
                };
                ele = {
                  sopsFile = ./secrets/hass.yaml;
                  owner = "hass";
                };
              };
            }
          ];
        };
      };
    };
}
