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
    musnix.url = "github:musnix/musnix";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprpaper.url = "github:hyprwm/hyprpaper";
    hyprpaper.inputs.nixpkgs.follows = "nixpkgs";
    hyprlock.url = "github:hyprwm/hyprlock";
    hyprlock.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:danth/stylix";
    sops-nix.url = "github:Mic92/sops-nix";
    bizhawk.url = "github:TASEmulators/BizHawk/master";
    bizhawk.flake = false;
    mac-brcm-fw = {
        url = "github:AdityaGarg8/Apple-Firmware";
        flake = false;
    };

    # Hyprland Plugins
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs =
    { self,
      nixpkgs,
      nix-stable,
      nixos-hardware,
      musnix,
      home-manager,
      hyprland,
      hyprpaper,
      hyprlock,
      hyprland-plugins,
      mac-brcm-fw,
      stylix,
      sops-nix,
      bizhawk,
      split-monitor-workspaces,
      ... }@inputs:
				let
					system = "x86_64-linux";
					overlay-stable = final: prev: {
            stable = import nix-stable { inherit system; config.allowUnfree = true; };
					};

				in
      {
      nixosModules."commonModules" = { config, lib, inputs, hyprland, hyprland-plugins, split-monitor-workspaces, ... }:{
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
          secrets."passwords/linux".neededForUsers = true;
          secrets = {
                "passwords/icloud" = { owner = "lily"; };
                "passwords/gmail/neuraria" = { owner = "lily"; };
                "passwords/gmail/simonsayslps" = { owner = "lily"; };
                "passwords/gmail/simonf" = { owner = "lily"; };
              };
        };

        nix.settings = {
          substituters = ["https://hyprland.cachix.org"];
          trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
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
    };
}
