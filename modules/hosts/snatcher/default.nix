{ self, inputs, ... }: {

    flake.nixosConfigurations.snatcher = inputs.nixpkgs.lib.nixosSystem {
        modules = [
            self.nixosModules.snatcherConfig
        ];
    };

}
