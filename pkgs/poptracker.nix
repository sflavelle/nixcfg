{ lib
, stdenv
, fetchFromGitHub
, SDL2
, SDL2_image
, SDL2_ttf
, openssl
, util-linux
, which
, gnome
}:

stdenv.mkDerivation rec {
    name = "poptracker";
    version = "0.25.8";

    src = fetchFromGitHub {
        owner = "black-sliver";
        repo = "PopTracker";
        rev = "v${version}";
        sha256 = "sha256-wP2d8cWNg80KUyw1xPQMriNRg3UyXgKaSoJ17U5vqCE=";
        fetchSubmodules = true;
    };

    nativeBuildInputs = [ SDL2 SDL2_ttf SDL2_image openssl util-linux ];
    buildInputs = [ SDL2 SDL2_ttf SDL2_image openssl which gnome.zenity ];



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
