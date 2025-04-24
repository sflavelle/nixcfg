{
  lib,
  pkgs,
  inputs,
  ...
}:

{
  nixpkgs.overlays = [ inputs.niri.overlays.niri ];

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gnome ];

  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
    settings.binds = {
      "Mod+T".action.spawn = "${pkgs.ghostty}/bin/ghostty";
      "Mod+Space".action.spawn = "${pkgs.fuzzel}/bin/fuzzel";
      "Mod+B".action.spawn = "${pkgs.ungoogled-chromium}/bin/chromium";
    };
  };
}
