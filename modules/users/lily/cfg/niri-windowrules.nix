{ lib, primaryMonitor, ... }:
{
  browserPip = {
    matches = [
      {
        app-id = "firefox";
        title = "Picture-in-Picture";
      }
      {
        app-id = "floorp";
        title = "Picture-in-Picture";
      }
      { title = "Picture in picture"; }
    ];
    open-floating = true;
    open-on-output = primaryMonitor.name;
    default-floating-position = {
      relative-to = "bottom-right";
      x = 0;
      y = 0;
    };
    default-column-width = { proportion = 1. / 5.; };
    default-window-height = { proportion = 1. / 5.; };
  };

  games = {
    matches = [
      { app-id = "^steam_app_"; }
      { app-id = "gzdoom"; }
      { app-id = "SpaceIdle"; }
      { title = "Ship of Harkinian"; }
      { app-id = "Celeste"; }
    ];
    open-on-workspace = "Games";
    open-floating = false;
    default-column-width = { proportion = 2. / 3.; };
    open-maximized = true;
  };
  chatPrograms = {
    matches = [
      { app-id = "discord"; }
      { app-id = "WebCord"; }
      { app-id = "element"; }
    ];
    open-on-workspace = "Communication";
  };
  bitwigStudio = {
    matches = [{ app-id = "com.bitwig.BitwigStudio"; }];
    open-on-workspace = "Audio";
  };
}
