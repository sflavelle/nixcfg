{ self, inputs, ...}: {

    flake.nixosModules.niri = { pkgs, lib, ... }: {
        programs.niri = {
            enable = true;
            package = self.packages.${pkgs.stdenv.hostPlatform.system}.neuri;
        };
        programs.dms-shell = {
            enable = true;
            systemd.enable = false;
        };
    };

    perSystem = { pkgs, lib, self', ... }: {
        packages.neuri = inputs.wrapper-modules.wrappers.niri.wrap {
            inherit pkgs;
            settings = {
                screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
                prefer-no-csd = true;

                xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

                input = {
                    keyboard = {
                        repeat-delay = 600;
                        repeat-rate = 25;
                        track-layout = "global";
                    };
                    touchpad = {
                        tap = _: {};
                        natural-scroll = _: {};
                    };
                    mouse.scroll-factor = 1.0;
#                     focus-follows-mouse = "max-scroll-amount=20%";
                    disable-power-key-handling = true;
                };
                layout = {
                    focus-ring.off = _: {};
                    border = {
                        on = _: {};
                        width = 2;
                        active-color = "#67d3ff";
                        inactive-color = "#003546";
                        urgent-color = "rgb(255 0 0)";
                    };
                    background-color = "transparent";

                };

                binds = {
                    "Mod+T".spawn-sh = lib.getExe self'.packages.neuAlacritty;
                    "Mod+Return".spawn-sh = "${lib.getExe self'.packages.neuAlacritty} --class=scratch -e ${lib.getExe pkgs.helix}";
                };

                spawn-at-startup = [
                    [ "dms" "run" ]
                ];
            };
        };
    };
}
