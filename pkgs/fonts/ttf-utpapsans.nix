{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  # python3,
  fontVariant
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ttf-utpapyrussans";
  version = "2016-02-08";

  src = fetchFromGitLab {
    owner = "cartr";
    repo = "undertale-fonts";
    tag = "master";
    hash = "";
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
    install -m444 -Dt $out/share/fonts/truetype ttf/Undertale${fontVariant}*.ttf
    runHook postInstall
  '';

  meta = {
    homepage = "http://cartr.gitlab.io/undertale-fonts";
    description = "Fan-made recreation of Undertale's pixellated Comic Sans and Papyrus fonts";
    license = [ lib.licenses.unfree ];
    platforms = lib.platforms.all;
    # maintainers = [ lib.maintainers.sflavelle ];
  };
})
