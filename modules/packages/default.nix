{ self, inputs, ...}: {

    perSystem = { pkgs, lib, self', ... }: {
        packages.neo = pkgs.callPackage ../../pkgs/neo.nix { };
        packages.vacuumtube = pkgs.callPackage ../../pkgs/vacuumtube.nix { };
    };
}
