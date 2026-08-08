{ self, inputs, ... }: {

    flake.nixosConfigurations.jevil = inputs.nixpkgs.lib.nixosSystem {
        modules = [
            self.nixosModules.jevilConfig
            self.nixosModules.commonSetup
            self.nixosModules.mountsHome
            self.nixosModules.niri
        ];
    };

}
