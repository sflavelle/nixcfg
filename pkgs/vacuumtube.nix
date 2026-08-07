{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  electron_42,
  copyDesktopItems,
  makeDesktopItem,
}:

buildNpmPackage (finalAttrs: {
  pname = "VacuumTube";
  version = "1.8.2";

  src = fetchFromGitHub {
    owner = "shy1132";
    repo = "VacuumTube";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KgXV6fSvV6jl8V2YEjJm+CIG8ATvb1/iEhLog91DPY0=";
  };

  electron = electron_42;

  npmDepsHash = "sha256-Wtyft343sSs018v5bagCvvta5z+yzU9IgkJ4LH+HQzs=";

  # The prepack script runs the build script, which we'd rather do in the build phase.
  npmPackFlags = [ "--ignore-scripts" ];

  npmBuildScript = "linux:build-unpacked";

  makeCacheWritable = true;

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = true;

  NODE_OPTIONS = "--openssl-legacy-provider";

  # desktopItem = makeDesktopItem {
  #   name = finalAttrs.pname;
  #   exec = finalAttrs.pname;
  #   icon = finalAttrs.pname;
  #   desktopName = "VacuumTube";
  #   categories = [ "AudioVideo" "Player" "Video" ];
  #   comment = "YouTube Leanback wrapper for the desktop";
  # };

  # extraInstallCommands = ''
  #   mkdir -p $out/share/applications
  #   cp -r ${finalAttrs.desktopItem}/share/applications/* $out/share/applications/
  # '';

  meta = {
    description = "YouTube Leanback wrapper for the desktop";
    homepage = "https://github.com/shy1132/VacuumTube";
    downloadPage = "https://github.com/shy1132/VacuumTube/releases";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
})