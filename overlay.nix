{ lib
, pkgs
, ...

}:

final: prev:

let
  inherit (final)
    kernelPatches
    linuxPackagesFor
    ;
in
rec {
  link-steamscreenshots = final.callPackage ./pkgs/link-steamscreenshots { };
  mpv-watch = final.callPackage ./pkgs/mpv-watch.nix {
    pydymenu = final.callPackage ./pkgs/pydymenu.nix { };
  };

  pidgin3 = final.callPackage ./pkgs/pidgin/pidgin3.nix {
    birb = final.callPackage ./pkgs/pidgin/birb.nix;
    seagull = final.callPackage ./pkgs/pidgin/seagull.nix;
    gplugin = final.callPackage ./pkgs/pidgin/gplugin.nix;
  };

  vacuumtube = final.callPackage ./pkgs/vacuumtube.nix { };
  hydratextclient = final.callPackage ./pkgs/aphydraclient.nix { };

  # Fonts
  otf-determination = final.callPackage ./pkgs/fonts/otf-determination.nix { };
  ttf-utpapyrus = final.callPackage ./pkgs/fonts/ttf-utpapsans.nix { fontVariant = "Papyrus"; };
  ttf-utsans = final.callPackage ./pkgs/fonts/ttf-utpapsans.nix { fontVariant = "Sans"; };

  # GSR (from Keenan Weaver's nix-config)
  gpu-screen-recorder = prev.callPackage ./pkgs/gpu-screen-recorder/gsr.nix { };
  gpu-screen-recorder-notification = prev.callPackage ./pkgs/gpu-screen-recorder/notif.nix { };
  gpu-screen-recorder-ui = prev.callPackage ./pkgs/gpu-screen-recorder/ui.nix { };

}
