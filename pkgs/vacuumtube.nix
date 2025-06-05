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
    hash = "";
  };

  appimageContents = appimageTools.extractType1 { inherit name src; };
in
appimageTools.wrapType2 rec {
  inherit pname version src;

  extraInstallCommands = ''
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=${meta.mainProgram}'
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