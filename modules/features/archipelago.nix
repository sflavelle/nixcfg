{ self, inputs, ... }: {

  flake.nixosModules.archipelago = { config, pkgs, ... }: {

      nixpkgs.overlays = [
          (final: prev: {
            archipelago = prev.archipelago.overrideAttrs (oldAttrs: {
              postInstall = (oldAttrs.postInstall or "") + ''
                cd $out/lib/python*/site-packages/worlds/
                rm -rf oot
                rm -rf tunic.apworld
                rm -rf celeste_open_world.apworld
              '';
            });
          })
        ];

      environment.systemPackages = with pkgs; [
        archipelago
        poptracker
      ];

  };
}
