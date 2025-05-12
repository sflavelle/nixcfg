{ lib, python3Packages, ... }:
python3Packages.buildPythonApplication rec {
  pname = "link-steamscreenshots";
  version = "unstable-2025-05-12";

  format = "other";

  propagatedBuildInputs = with python3Packages; [
    rich
    requests
  ];

  dontBuild = true;
  dontUnpack = true;
  installPhase = "install -Dm755 ${./${pname}.py} $out/bin/${pname}";
}
