{ lib, fetchurl, stdenv, makeWrapper, meson, ninja, cmake,
gi-docgen, pkg-config, glib, gobject-introspection, sqlite }:
stdenv.mkDerivation rec {
  pname = "seagull";
  version = "0.4.0";

  src = fetchurl {
    url = "mirror://sourceforge/pidgin/seagull-${version}.tar.xz";
    sha256 = "sha256-dJauzgiwV1xIzu7u5IwKc4ElWMmGIp4kEIBWhy7h5U0=";
  };

  nativeBuildInputs = [ meson ninja cmake ];

  buildInputs = [ 
    gi-docgen
    glib
    gobject-introspection
    sqlite
    pkg-config
  ];
}