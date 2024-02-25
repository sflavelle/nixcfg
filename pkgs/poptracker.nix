{ lib
, stdenv
, fetchFromGitHub
, SDL2
, SDL2_image
, SDL2_ttf
, openssl
, util-linux
, python310Packages
, python310
, which
}:

stdenv.mkDerivation rec {
    name = "poptracker";
    version = "0.25.7";

    src = fetchFromGitHub {
        owner = "black-sliver";
        repo = "PopTracker";
        rev = "v${version}";
        sha256 = "sha256-wP2d8cWNg80KUyw1xPQMriNRg3UyXgKaSoJ17U5vqCE=";
        fetchSubmodules = true;
    };

    nativeBuildInputs = [ SDL2 SDL2_ttf SDL2_image openssl util-linux ];
    buildInputs = [ SDL2 SDL2_ttf SDL2_image openssl which python310
      python310Packages.tkinter python310Packages.dbus-python ];



    installPhase = ''
    	install -Dm755 -t $out/bin build/linux-x86_64/poptracker
    	cp -r assets $out/bin
    '';

    meta = with lib; {
       homepage = "https://github.com/black-sliver/PopTracker";
       description = "A universal, scriptable tracker for game randomizers";
       license = licenses.gpl3Only;
       platforms = platforms.unix;
       mainProgram = "poptracker";
    };
}
