{ lib
, stdenv
, fetchFromGitHub
, python312Packages
, mpv
, fzf
, rofi
, pydymenu
,
}:
python312Packages.buildPythonApplication rec {
  pname = "mpv-watch";
  version = "unstable-2025-01-16";
  src = fetchFromGitHub {
    owner = "sflavelle";
    repo = "dots";
    rev = "cdde9d919f9bfb1c5e812d566212b2350dc8be79";
    hash = "sha256-rHpd+UqOw1j/o2ird3MouT6/jbjT1VUpPnngKun2l6A=";
  };

  dependencies = [
    pydymenu
    mpv
    fzf
    rofi
    python312Packages.pyyaml
  ];

  pyproject = false;
  build-tools = [

  ];

  patchPhase = ''
    runHook prePatch
    sed -i 's,/usr/bin/mpv,mpv,g' dot_local/bin/executable_watch
    runHook postPatch
  '';

  installPhase = ''install -Dm755 dot_local/bin/executable_watch $out/bin/mpv-watch'';
  postInstall = ''
    wrapProgram $out/bin/mpv-watch \
      --set PATH ${lib.makeBinPath [mpv fzf rofi]}
  '';

  meta = {
    description = "Helper script to easily launch a playlist in MPV";
    homepage = "https://github.com/sflavelle/dots/blob/master/dot_local/bin/executable_watch";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.unfree; # Not set
    maintainers = with lib.maintainers; [ ];
  };
}
