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
  };

  outputs = { self, nixpkgs, musnix, home-manager, hyprland, stylix, ... }@inputs: {
    nixosModules."commonModules" = { config, lib, inputs, ... }: {
        imports = [
            inputs.home-manager.nixosModules.home-manager
            inputs.stylix.nixosModules.stylix
            inputs.sops-nix.nixosModules.sops
            ./users/lily.nix
        ];

        home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
        };

        stylix = {
            image = lib.mkDefault /home/lily/Pictures/Wallpapers/Mac/10-3-6k.jpg;
        };

        sops = {
            defaultSopsFile = ./secrets/secrets.yaml;
            age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
            age.generateKey = false;
        };
    };
    nixosConfigurations = {
      "snatcher" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };  # pass custom arguments into all sub module.
        modules = [
          ./hosts/snatcher.nix
          ./common/desktop.nix
          ./users/lily.nix
          musnix.nixosModules.musnix
          self.nixosModules.commonModules
	  {
	     stylix.image = /home/lily/Pictures/Wallpapers/wallhaven/wallhaven_lq88ky_1920x1080.jpg;
          }
        ];
      };
      "minion" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
              ./hosts/minion.nix
              ./common/desktop.nix
              ./users/lily.nix
              self.nixosModules.commonModules
              {
                  stylix.image = /home/lily/Pictures/Wallpapers/Windows/1920x1200.jpg;
              }

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
                      elevation = {
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
