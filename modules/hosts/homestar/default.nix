{ self, inputs, ... }: {

    flake.nixosConfigurations.homestar = inputs.mobile-nixos.lib.configuration {
        device = "lenovo-wormdingler";
    };

}
