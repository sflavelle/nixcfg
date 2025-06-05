{
  lib,
  appimageTools,
  fetchurl,
}:

let
  version = "1.1.0";
  pname = "VacuumTube";

  src = fetchurl {
    url = "https://github.com/shy1132/VacuumTube/releases/download/v${version}/VacuumTube-x86_64.AppImage";
    hash = "sha256-4xkQz2QulA/3UBoMIJPjOF+7BSWEh8Fa/FsqQ3KDmKo=";
  };

in
appimageTools.wrapType2 rec {
  inherit pname version src;

  meta = {
    description = "YouTube Leanback wrapper for the desktop";
    homepage = "https://github.com/shy1132/VacuumTube";
    downloadPage = "https://github.com/shy1132/VacuumTube/releases";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [  ];
    platforms = [ "x86_64-linux" ];
  };
}