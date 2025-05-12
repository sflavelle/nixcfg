{ lib, python3Packages, ... }:
stdenv.mkDerivation {
  pname = "link-steamscreenshots";
  version = "unstable-2025-05-12"
  propagatedBuildInputs = with python3Packages; [
    rich
    requests
  ];

  dontUnpack = true;
  installPhase = "install -Dm755 ${./${pname}.py} $out/bin/${pname}";
};
