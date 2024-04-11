{ lib
, pkgs
}:
    pkgs.appimageTools.wrapType2 {
        name = "r-quick-share";
        version = "0.5.0";
        src = pkgs.fetchurl {
           url = "https://github.com/Martichou/rquickshare/releases/download/v0.5.0/r-quick-share_0.5.0_amd64_GLIBC-2.31.AppImage";
           hash = "";
        };
    };
