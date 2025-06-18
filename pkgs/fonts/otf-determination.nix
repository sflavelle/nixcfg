{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  # python3
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "otf-determination";
  version = "2015-11-16";

  src = fetchurl {
    url = "https://github.com/sflavelle/nixcfg/raw/5d7c9553b01ef310861e3b7ea4d6eb5f02a46709/pkgs/fonts/DTM.ZIP";
    hash = "sha256-DWGMpT4j5kKwfRbiFelXNRURmSrPC+aenlXShEZZ3Nk=";
  };

  # Please note that the official download link for the fonts
  # is a MediaFire page. For reproducibility, this is why
  # the zip is bundled directly in this repository.

  nativeBuildInputs = [
    unzip
    # (python3.withPackages (
    #   pp: with pp; [
    #     mediafire-dl
    #   ]
    # ))
  ];

  unpackPhase = ''
    unzip $src
  '';

  buildPhase = ''
    runHook preBuild
    # nothing
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
