  { config, lib, ...}:
  {
  # Keyboard customization
  sound.mediaKeys.enable = true;
  hardware.brillo.enable = true;
  services.keyd = {
      enable = true;
      keyboards = {
          chromekb = {
              ids = [ "0001:0001" ];
              settings = {
                  main = {
                      f1 = "prev";
                      f2 = "next";
                      f3 = "refresh";
                      f4 = "f11";
                      f5 = "cyclewindows";
                      f6 = "brightnessdown";
                      f7 = "brightnessup";
                      f8 = "mute";
                      f9 = "volumedown";
                      f10 = "volumeup";
                  };
                  "control+alt" = {
                      f1 = "f1";
                      f2 = "f2";
                      f3 = "f3";
                      f4 = "f4";
                      f5 = "f5";
                      f6 = "f6";
                      f7 = "f7";
                      f8 = "f8";
                      f9 = "f9";
                      f10 = "f10";
                  };
                  control = {
                    left = "home";
                    right = "end";
                    up = "pageup";
                    down = "pagedown";
                  };
              };
          };
      };
  };

  }