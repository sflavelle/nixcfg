{ lib
, appimageTools
, copyDesktopItems
, makeDesktopItem
}:
    pkgs.appimageTools.wrapType2 {
        name = "r-quick-share";
        version = "0.5.0";
        src = pkgs.fetchurl {
           url = "https://github.com/Martichou/rquickshare/releases/download/v0.5.0/r-quick-share_0.5.0_amd64_GLIBC-2.31.AppImage";
           hash = "sha256-ilVXMyPAxn58YNiMY2Q8PAasYe7XSq01Mj8i458VvsY=";
        };

        desktopItems = [
            (makeDesktopItem {
                name = "r-quick-share";
                exec = "r-quick-share";
                icon = "r-quick-share";
                desktopName = "Quick Share";
                genericName = "Android file sharing";
                categories = "Utilities;Internet;";
            })
        ];
    }
