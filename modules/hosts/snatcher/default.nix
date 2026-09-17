{ self, inputs, ... }: {

    flake.nixosConfigurations.snatcher = inputs.nixpkgs.lib.nixosSystem {
        modules = [
            self.nixosModules.snatcherConfig
            self.nixosModules.commonSetup
            self.nixosModules.gaming
            self.nixosModules.archipelago
            self.nixosModules.userLily
            self.nixosModules.mountsHome
            self.nixosModules.niri
            self.nixosModules.snatcherNiri
            self.nixosModules.umbriel
            self.nixosModules.snatcherUmbriel
            self.nixosModules.snatcherHermes

            # inputs.comfyui-nix.nixosModules.default
        ];
    };

}
