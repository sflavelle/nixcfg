{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonApplication,
  pydymenu,
}:
let
  dots = fetchFromGitHub {
    owner = "sflavelle";
    repo = "dots";
    rev = "cdde9d919f9bfb1c5e812d566212b2350dc8be79";
    hash = "sha256-rHpd+UqOw1j/o2ird3MouT6/jbjT1VUpPnngKun2l6A=";
  };

in buildPythonApplication rec {
  pname = "mpv-watch";
  version = "unstable-2025-01-16";
  src = ${dots}/dot_local/bin/executable_watch;
}
  dependencies = [
    pydymenu
  ];

  meta = {
    description = "Helper script to easily launch a playlist in MPV";
    homepage = "https://github.com/sflavelle/dots/blob/master/dot_local/bin/executable_watch";
    license = lib.licenses.unfree; # Not set
    maintainers = with lib.maintainers; [ ];
  }