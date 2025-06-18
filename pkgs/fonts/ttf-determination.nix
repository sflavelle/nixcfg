{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  # python3
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "otf-determination";
  version = "2015-11-16";

  src = fetchFromGitLab {
    owner = "cartr";
    repo = "undertale-fonts";
    rev = "master";
    hash = "sha256-TnFVA4441yujp4LN3gD4EaqptH6MfxOBqq5m9LrZZFE=";
  };

  # Please note that the official download link for the fonts
  # is a MediaFire page.
  # The Gitlab source seems the most 'stable' source for now

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
    install -m444 -Dt $out/share/fonts/truetype ttf/Determination*.ttf
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
