{
  lib,
  appimageTools,
  fetchurl,
  copyDesktopItems,
  makeDesktopItem,
}:

let
  version = "1.2.0";
  pname = "VacuumTube";

  src = fetchurl {
    url = "https://github.com/shy1132/VacuumTube/releases/download/v${version}/VacuumTube-x86_64.AppImage";
    hash = "sha256-IXk8vsxhDn11awR4MJxbZ6vq2adJib1a0SjDkC6Cgkc=";
  };

in
appimageTools.wrapType2 rec {
  inherit pname version src;

  nativeBuildInputs = [ copyDesktopItems ];

  desktopItem = makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "VacuumTube";
      categories = [ "AudioVideo" "Player" "Video" ];
      comment = "YouTube Leanback wrapper for the desktop";
    };

  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cp -r ${desktopItem}/share/applications/* $out/share/applications/
    '';

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