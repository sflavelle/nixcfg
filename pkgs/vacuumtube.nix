{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  electron_42,
  zip,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
}:

buildNpmPackage (finalAttrs: {
  pname = "VacuumTube";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "shy1132";
    repo = "VacuumTube";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OA3UjqJTELqe2nn2y2/ztQxipENt873Iw5WDsjyjjRc=";
  };

  electron = electron_42;

  npmDepsHash = "sha256-kKyOjpl6LwUOdWP5+AN8m2RxMcDhzov3YLw1rhUna3k=";

  dontNpmBuild = true;
  makeCacheWritable = true;
  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/VacuumTube $out/bin

    # Copy the application source alongside installed node_modules
    cp -r . $out/share/VacuumTube

    # Create an executable wrapper pointing to the Nixpkgs electron binary
    makeWrapper ${finalAttrs.electron}/bin/electron $out/bin/VacuumTube \
      --add-flags "$out/share/VacuumTube"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "VacuumTube";
      exec = "VacuumTube";
      icon = "VacuumTube";
      desktopName = "VacuumTube";
      categories = [ "AudioVideo" "Player" "Video" ];
      comment = "YouTube Leanback wrapper for the desktop";
    })
  ];

  meta = {
    description = "YouTube Leanback wrapper for the desktop";
    homepage = "https://github.com/shy1132/VacuumTube";
    downloadPage = "https://github.com/shy1132/VacuumTube/releases";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
})