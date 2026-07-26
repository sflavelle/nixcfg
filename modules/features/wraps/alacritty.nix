{ self, inputs, ...}: {

    flake.nixosModules.terminal = { pkgs, lib, self', ... }: {
        environment.systemPackages = [
          self'.packages.neuAlacritty
        ];
        fonts.packages = with pkgs; [
          anakron
        ];
    };

    perSystem = { pkgs, lib, self', ... }: {
        packages.neuAlacritty = inputs.wrapper-modules.wrappers.alacritty.wrap {
            inherit pkgs;
            settings = {
              font.normal = {
                family = "ANAKRON Nerd Font Mono";
              };
              font.size = 9;

              colors.transparent_background_colors = false;

              window = {
                opacity = 0.9;
                blur = true;
              };
            };
        };
    };
}
