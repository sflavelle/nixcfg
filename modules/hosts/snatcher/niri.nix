{ self, inputs, ... }: {

  flake.nixosModules.snatcherNiri = { config, pkgs, ... }:

  {
    programs.niri.package = self.packages.${pkgs.stdenv.hostPlatform.system}.neuri.wrap {
      settings = {
            outputs = {
                "Philips Consumer Electronics Company PHL 216V6 ZV01929011836" = {
                    scale = 1.0;
                    position = _: {
                        props = {
                            x = 0;
                            y = 0;
                        };
                    };
                    mode = "1920x1080";
                };
                "Lenovo Group Limited R45w-30 UPP07HR8" = {
                    scale = 1.0;
                    focus-at-startup = _: {};
                    variable-refresh-rate = _: {};
                    position = _: {props = {
                        x = 0;
                        y = 1080;
                    };};
                    mode = "5120x1440";
                    layout = {
                        default-column-width = { proportion = 0.25; };
                        preset-column-widths = [
                            { proportion = 0.25; }
                            { proportion = 0.333; }
                            { proportion = 0.5; }
                            { proportion = 0.666; }
                            { proportion = 0.75; }
                        ];
                    };
                };
                "Microstep MSI G24C6 0x00000243" = {
                    scale = 1;
                    position = _: {props = {
                        x = 2520;
                        y = 0;
                    };};
                    mode = "1920x1080@60";
                };
                "Graphica Computer HD Display Unknown" = {
                    scale = 1.25; # 1 is just a touch too small :(
                    position = _: {props = {
                        x = 1920;
                        y = 2520;
                    };};
                    mode = "1920x720";
                };
            };
            workspaces = {
                "Browser" = {
                    open-on-output = "Lenovo Group Limited R45w-30 UPP07HR8";
                    
                };
                "Chat" = {
                    open-on-output = "Microstep MSI G24C6 0x00000243";
                    
                };
                "Games" = {
                    open-on-output = "Lenovo Group Limited R45w-30 UPP07HR8";
                    
                };
                "Work" = {
                    open-on-output = "Lenovo Group Limited R45w-30 UPP07HR8";
                    
                };
                "Utility" = {
                    open-on-output = "Graphica Computer HD Display Unknown";
                    
                };
                "Media" = {
                    open-on-output = "Philips Consumer Electronics Company PHL 216V6 ZV01929011836";
                    
                };
                "Archipelago" = {
                    open-on-output = "Graphica Computer HD Display Unknown";   
                };
            };
        };
    };
  };
}
