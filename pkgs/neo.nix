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
  pname = "neo";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "hughhowey";
    repo = "neo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mg27M+C7FntzFofrFbMHqn86YGg4jY+8FW9dyz48X+U=";
  };

  electron = electron_42;

  npmDepsHash = "sha256-bP8hcyP8AZ3bWFYSJtTHKNmavm7uzJR4WKpy5m2uNRY=";

  dontNpmBuild = true;
  makeCacheWritable = true;
  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/neo $out/bin

    # Copy the application source alongside installed node_modules
    cp -r . $out/share/neo

    # Create an executable wrapper pointing to the Nixpkgs electron binary
    makeWrapper ${finalAttrs.electron}/bin/electron $out/bin/neo \
      --add-flags "$out/share/neo"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "neo";
      exec = "neo";
      icon = "neo";
      desktopName = "neo";
      categories = [ "Office" ];
      comment = "A novel-writing tool created by a novelist";
    })
  ];

  meta = {
    description = "A novel-writing tool created by a novelist";
    homepage = "https://github.com/hughhowey/neo";
    downloadPage = "https://github.com/hughhowey/neo/releases";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
})