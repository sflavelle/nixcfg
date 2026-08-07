{ self, inputs, ...}: {

    perSystem = { pkgs, lib, self', ... }: {
        packages.vacuumtube = pkgs.callPackage ../../pkgs/vacuumtube.nix { };
    };
}
