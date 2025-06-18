{
  lib,
  stdenvNoCC,
  fetchzip,
  # python3
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "otf-determination";
  version = "2015-11-16";

  src = fetchzip {
    url = ./DTM.ZIP;
    hash = "";
  };

  # Please note that the official download link for the fonts
  # is a MediaFire page. For reproducibility, this is why
  # the zip is bundled directly in this repository.

  nativeBuildInputs = [
    # (python3.withPackages (
    #   pp: with pp; [
    #     mediafire-dl
    #   ]
    # ))
  ];

  buildPhase = ''
    runHook preBuild
    # ./build.sh
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -m444 -Dt $out/share/fonts/opentype *.otf
    runHook postInstall
  '';

  meta = {
    homepage = "https://www.behance.net/gallery/31268855/Determination-Better-Undertale-Font";
    description = "Fan-made recreation of Undertale's main interface font by Harry Wakamatsu";
    license = [ lib.licenses.unfree ];
    platforms = lib.platforms.all;
    # maintainers = [ lib.maintainers.sflavelle ];
  };
})
