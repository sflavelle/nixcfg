{ self, inputs, ...}: {

    flake.nixosModules.niri = { pkgs, lib, ... }: {
        programs.niri = {
            enable = true;
            package = lib.mkDefault self.packages.${pkgs.stdenv.hostPlatform.system}.neuri;
        };
        programs.dms-shell.enable = true;
    };

    perSystem = { pkgs, lib, self', ... }: {
        packages.neuri = inputs.wrapper-modules.wrappers.niri.wrap {
            inherit pkgs;
            extraSettings = [
              { include = [ {optional = true; } "~/.config/niri/dms-theme-sync.kdl"];}  
              { include = [ {optional = true; } "~/.config/niri/dms/wpblur.kdl"];}  
              { include = [ {optional = true; } "~/.config/niri/dms/layout.kdl"];}  
              { include = [ {optional = true; } "~/.config/niri/dms/alttab.kdl"];}  
              { include = [ {optional = true; } "~/.config/niri/dms/colors.kdl"];}  
              { include = [ {optional = true; } "~/.config/niri/dms/cursor.kdl"];}  
              { include = [ {optional = true; } "~/.config/niri/dms/binds.kdl"];}  
              { include = [ {optional = true; } "~/.config/niri/dms/outputs.kdl"];}  
              { include = [ {optional = true; } "~/.config/niri/dms/windowrules.kdl"];}  
            ];
            settings = {
                screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
                prefer-no-csd = true;

                xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

                hotkey-overlay.skip-at-startup = [];

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
                    focus-follows-mouse = _: {
                        props = {
                            max-scroll-amount = "20%";
                        };};
                    disable-power-key-handling = true;
                };

                cursor = {
                    xcursor-theme = "Posy_Cursor";
                    xcursor-size = 24;
                    hide-when-typing = [];
                    hide-after-inactive-ms = 3000;
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

                workspaces = {
                    "Browser" = {};
                    "Chat" = {};
                    "Games" = {};
                    "Work" = {};
                    "Utility" = {};
                    "Media" = {};
                };

                binds = let
                    dms = lib.getExe pkgs.dms-shell;
                    ipc = "${dms} ipc call";
                    term = lib.getExe self'.packages.neuAlacritty;
                in {
                    # Window Management
                    "Mod+Q".close-window = _: {};
                    "Mod+F".maximize-column = _: {};
                    "Mod+Shift+F".fullscreen-window = _: {};
                    "Mod+Ctrl+F".maximize-window-to-edges = _: {};
                    "Super+Alt+F".toggle-windowed-fullscreen = _: {};

                    "Mod+Shift+Tab".toggle-window-floating = _: {};

                    "Mod+C".center-column = _: {};

                    "Mod+T".spawn-sh = term;
                    "Mod+Return".spawn-sh = "${ipc} notepad toggle";

                    "Mod+E".spawn-sh = "${term} --class=yazi -e ${lib.getExe pkgs.yazi}";
                    "Mod+Shift+E".spawn-sh = "${ipc} defaultApp fileManager";
                    "Mod+B".spawn-sh = "${ipc} defaultApp browser";

                    "Mod+V".spawn-sh = "${ipc} clipboard toggle";
                    "Mod+Escape".spawn-sh = "${ipc} processlist toggle";
                    "Mod+Shift+Escape".spawn-sh = "${term} --class=btop -e ${lib.getExe pkgs.btop}";
                    "Mod+Space".spawn-sh = "${ipc} spotlight toggle";
                    "Mod+F2".spawn-sh = "${ipc} spotlight-bar toggle";


                    "Mod+R".switch-preset-column-width = [ ];
                    "Mod+Ctrl+R".reset-window-height = [ ];
                    "Mod+Minus".set-column-width = "-10%";
                    "Mod+Equal".set-column-width = "+10%";

                    "Mod+Left".focus-column-left = [ ];
                    "Mod+Right".focus-column-right = [ ];
                    "Mod+Up".focus-window-up = [ ];
                    "Mod+Down".focus-window-down = [ ];

                    "Mod+Shift+Left".move-column-left = [ ];
                    "Mod+Shift+Right".move-column-right = [ ];
                    "Mod+Shift+Up".move-window-up = [ ];
                    "Mod+Shift+Down".move-window-down = [ ];

                    "Mod+Ctrl+Left".focus-monitor-left = [ ];
                    "Mod+Ctrl+Right".focus-monitor-right = [ ];
                    "Mod+Ctrl+Up".focus-monitor-up = [ ];
                    "Mod+Ctrl+Down".focus-monitor-down = [ ];

                    "Mod+Shift+Ctrl+Left".move-column-to-monitor-left = [ ];
                    "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = [ ];
                    "Mod+Shift+Ctrl+Up".move-window-to-monitor-up = [ ];
                    "Mod+Shift+Ctrl+Down".move-window-to-monitor-down = [ ];

                    "Super+Ctrl+Alt+Left".move-workspace-to-monitor-left = [ ];
                    "Super+Ctrl+Alt+Right".move-workspace-to-monitor-right = [ ];
                    "Super+Ctrl+Alt+Up".move-workspace-to-monitor-up = [ ];
                    "Super+Ctrl+Alt+Down".move-workspace-to-monitor-down = [ ];

                    "Mod+1".focus-workspace = 1;
                    "Mod+2".focus-workspace = 2;
                    "Mod+3".focus-workspace = 3;
                    "Mod+4".focus-workspace = 4;
                    "Mod+5".focus-workspace = 5;
                    "Mod+6".focus-workspace = 6;
                    "Mod+7".focus-workspace = 7;
                    "Mod+8".focus-workspace = 8;
                    "Mod+9".focus-workspace = 9;
                    "Mod+0".focus-workspace = 10;
                    "Mod+Shift+1".move-column-to-workspace = 1;
                    "Mod+Shift+2".move-column-to-workspace = 2;
                    "Mod+Shift+3".move-column-to-workspace = 3;
                    "Mod+Shift+4".move-column-to-workspace = 4;
                    "Mod+Shift+5".move-column-to-workspace = 5;
                    "Mod+Shift+6".move-column-to-workspace = 6;
                    "Mod+Shift+7".move-column-to-workspace = 7;
                    "Mod+Shift+8".move-column-to-workspace = 8;
                    "Mod+Shift+9".move-column-to-workspace = 9;
                    "Mod+Shift+0".move-column-to-workspace = 10;

                    "Mod+BracketLeft".consume-or-expel-window-left = [ ];
                    "Mod+BracketRight".consume-or-expel-window-right = [ ];

                    "Print".screenshot = [ ];
                    "Ctrl+Print".screenshot-screen = [ ];
                    "Alt+Print".screenshot-window = [ ];

                    "Mod+Period".clear-dynamic-cast-target = [ ];
                    "Mod+Shift+Period".set-dynamic-cast-window = [ ];
                    "Mod+Ctrl+Period".set-dynamic-cast-monitor = [ ];

                    "Mod+Slash".toggle-overview = [ ];
                    "Ctrl+Alt+Delete".spawn-sh = "${ipc} powermenu toggle";
                    "Mod+Comma".spawn-sh = "${ipc} settings toggle";
                    "Mod+L".spawn-sh = "${ipc} lock lock";

                    # Multimedia Keys

                    XF86AudioLowerVolume.spawn-sh = "${ipc} audio decrement";
                    XF86AudioMicMute.spawn-sh = "${ipc} audio micmute";
                    XF86AudioMute.spawn-sh = "${ipc} audio mute";
                    XF86AudioRaiseVolume.spawn-sh = "${ipc} audio increment";

                    XF86MonBrightnessDown.spawn-sh = "${ipc} brightness decrement";
                    XF86MonBrightnessUp.spawn-sh = "${ipc} brightness decrement";
                };

                window-rules = [
                    {
                        matches = [
                            { app-id = "^steam$"; }
                            { app-id = "heroic"; }
                            { app-id = "^love$"; title="Olympus"; }
                            { app-id = "lutris"; }
                        ];
                        open-on-workspace = "Games";
                    }
                    {
                        matches = [
                            { app-id = "discord"; }
                            { app-id = "WebCord"; }
                            { app-id = "vesktop"; }
                            { app-id = "element"; }
                            { app-id = "fluxer"; }
                        ];
                        open-on-workspace = "Chat";
                        background-effect.blur = true;
                    }
                    {
                        matches = [
                            { app-id = "firefox"; title="Picture-in-Picture"; }
                            { app-id = "floorp"; title="Picture-in-Picture"; }
                            { app-id = "zen"; title="Picture-in-Picture"; }
                            { title = "Picture in picture"; }
                        ];
                        open-floating = true;
                        # default-floating-position = {
                        #     relative-to = "bottom-right";
                        #     x = 0;
                        #     y = 0;
                        # };
                    }
                    {
                        matches = [
                            { app-id = "com.danklinux.dms"; }
                        ];
                        open-floating = true;
                        background-effect.blur = true;
                    }
                    {
                        matches = [ { at-startup = true; } ];
                        open-focused = false;
                    }
                    {
                        matches = [
                            { app-id = "^org.wezfurlong.wezterm$"; }
                            { app-id = "Alacritty"; }
                            { app-id = "ghostty"; }
                            { app-id = "kitty"; }
                        ];
                        draw-border-with-background = false;
                        background-effect.blur = true;
                    }

                    {
                        matches = [
                            { app-id="^steam_app_"; }
                            { app-id="gzdoom"; }
                            { app-id="uzdoom"; }
                            { app-id="SpaceIdle"; }
                            { title="Ship of Harkinian"; }
                            { app-id="Celeste"; }
                            { app-id="gmod"; }
                            { app-id="SMB1R"; }
                            { app-id="hollow_knight"; }
                            { app-id="hitman3"; }
                            { app-id="sm64coopdx"; }
                            { app-id="Refunct-Linux-Shipping"; }
                            { app-id="gamescope"; }
                            { app-id="Minecraft"; }
                            { app-id="mcpelauncher-client"; }
                            { app-id="p2ce"; }
                            { app-id="^Haste.x86_64$"; }
                            { app-id="^dusk$"; }
                            { app-id="^com.twilitrealm.dusk"; }
                            { app-id="MarbleItUp"; }
                        ];
                        excludes = [
                            { app-id="steam_app_570940"; title="Archipelago Client"; }
                        ];
                        open-on-workspace = "Games";
                        open-focused = true;
                        open-floating = false;
                        open-fullscreen = true;
                        variable-refresh-rate = true;
                        default-column-width = { fixed = 2468; };
                    }

                    {
                        matches = [
                            { app-id="com.bitwig.BitwigStudio"; }
                        ];
                        open-on-workspace = "Work";
                        open-focused = true;
                        open-maximized-to-edges = true;
                    }

                    {
                        matches = [
                            { app-id="steam_app_570940"; title="Archipelago Client"; }
                            { app-id="^Archipelago"; }
                            { app-id="vacuumtube";}
                        ];
                        open-on-workspace = "Archipelago";
                    }

                    {
                        matches = [
                            { app-id="btop";}
                        ];
                        open-on-workspace = "Utility";
                    }

                    {
                        matches = [
                            { app-id="feishin"; }
                            { app-id="mpv";}
                            { app-id="vacuumtube";}
                        ];
                        open-on-workspace = "Media";
                        open-maximized-to-edges = true;
                    }
                ];

                spawn-at-startup = [
                    [ (lib.getExe pkgs.voxtype) ]
                ];
            };
        };
    };
}
