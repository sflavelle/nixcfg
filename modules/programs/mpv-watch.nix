{ config, lib, pkgs, system, outputs, ... }:
let
  cfg = config.programs.mpv-watch;

  settingsFormat = pkgs.formats.yaml { };
  settingsFile = settingsFormat.generate "watch.yaml" cfg.settings;
  configFilePath = "${config.xdg.configHome}/watch.yaml";
in
{
  options.programs.mpv-watch = {
    enable = lib.mkEnableOption "mpv-watch";
    package = lib.mkPackageOption "mpv-watch" {
      default = [ outputs.packages.${system}.mpv-watch ];
    };
    settings = mkOption {
      type = settingsFormat.type;
      default = {
        "Watch Later" = "https://www.youtube.com/playlist?list=WL";
      };
      example = {
        "Watch Later" = "https://www.youtube.com/playlist?list=WL";
        "raocow: Celeste" = {
          url = "https://www.youtube.com/playlist?list=PLQhrpbbm5TDLuPoeFgmN_vWNIm74dhOJG";
          remember_progress = true;
        };
        "Mindcrack: Trouble in Terrorist Town" = {
          shuffle = true;
          url = "https://www.youtube.com/playlist?list=PLNiFIwkRDS3GrgvJOmDFW6q0tDqY-QEwO";
        };
      };
      description = ''
        Configuration of the set of playlists and videos to show.
        Playlists with no extra configuration can be specified with its URL string directly.
        Otherwise accepts an attrset: `url` specifies the URL (required), `newest_first` reverses the play order if true, `shuffle` randomises the play order, and `remember_progress` saves the playlist index of the current video on quit.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];
    xdg.configFile."watch.yaml".source = settingsFile;
  };
}
