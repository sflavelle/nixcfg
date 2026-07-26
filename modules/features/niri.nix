{ self, inputs, ...}: {

    flake.nixosModules.niri = { pkgs, lib, ... }: {
        programs.niri = {
            enable = true;
            package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
        };
        programs.dms-shell = {
            enable = true;
            systemd.enable = false;
        };
    };

    perSystem = { pkgs, lib, ... }: {
        packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
            settings = {
                screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
                prefer-no-csd = true;
                input = {
                    keyboard = {
                        repeat-delay = 600;
                        repeat-rate = 25;
                        track-layout = "global";
                    };
                    touchpad = {
                        tap = true;
                        natural-scroll = true;
                    };
                    mouse.scroll-factor = 1.0;
                    focus-follows-mouse.max-scroll-amount = "20%";
                    disable-power-key-handling = true;
                };
                layout = {
                    gaps = 8;
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
                    "Mod+T".spawn-sh = lib.getExe pkgs.alacritty;
                    "Mod+Return".spawn-sh = "${lib.getExe pkgs.alacritty} --class=scratch -e helix";
                };

                spawn-at-startup = [
                    [ "dms" "run" ]
                ];
            };
        };
    };
}
