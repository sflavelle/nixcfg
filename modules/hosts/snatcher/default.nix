{ self, inputs, ... }: {

    flake.nixosConfigurations.snatcher = inputs.nixpkgs.lib.nixosSystem {
        modules = [
            self.nixosModules.snatcherConfig
            self.nixosModules.commonSetup
            self.nixosModules.mountsHome
            self.nixosModules.niri
        ];
    };

}
