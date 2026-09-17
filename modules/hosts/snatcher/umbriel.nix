{ self, inputs, ... }: {

  flake.nixosModules.snatcherUmbriel = { config, pkgs, ... }:

  {
    home-manager.users.lily.programs.umbriel.settings = {
            environment = {
                PROTON_ENABLE_WAYLAND = "1";
                DXVK_HDR = "1";
            };
            input.tablet = {
                enabled = true;
                map_to_output = "Graphica Computer HD Display Unknown";
            };
            output = {
                "Philips Consumer Electronics Company PHL 216V6 ZV01929011836" = { # Top-Left
                    scale = 1.0;
                    position = [ 0 0 ];
                    mode = "1920x1080";
                };
                "Lenovo Group Limited R45w-30 UPP07HR8" = { # Primary
                    scale = 1.0;
                    tearing = true;
                    vrr = "always";
                    position = [0 1080];
                    mode = "5120x1440@165";
                    layout.scrolling.default_extent_fraction = 0.25;
                };
                "Microstep MSI G24C6 0x00000243" = { # Top-Right
                    scale = 1;
                    position = [ 2520 0 ];
                    mode = "1920x1080@60";
                };
                "Graphica Computer HD Display Unknown" = { # Mini Display
                    scale = 1.25; # 1 is just a touch too small :(
                    position = [ 1920 2520 ];
                    mode = "1920x720";
                };
            };
            workspace = [
                {
                    name = "Browser";
                    output = "Lenovo Group Limited R45w-30 UPP07HR8";
                    layout.mode = "master";
                    layout.master.position = "center";
                }
                {
                    name = "Chat";
                    output = "Microstep MSI G24C6 0x00000243";
                }
                {
                    name = "Games";
                    output = "Lenovo Group Limited R45w-30 UPP07HR8";
                }
                {
                    name = "Work";
                    output = "Lenovo Group Limited R45w-30 UPP07HR8";
                }
                {
                    name = "Sysmon";
                    output = "Graphica Computer HD Display Unknown";
                    layout.mode = "dwindle";
                }
                {
                    name = "Media";
                    output = "Philips Consumer Electronics Company PHL 216V6 ZV01929011836";
                    layout.mode = "dwindle";
                }
                {
                    name = "Dashboard";
                    output = "Philips Consumer Electronics Company PHL 216V6 ZV01929011836";
                    layout.mode = "master";
                }
                {
                    name = "Archipelago";
                    output = "Graphica Computer HD Display Unknown";
                    layout.mode = "master";
                }
            ];
        };
    };
}
