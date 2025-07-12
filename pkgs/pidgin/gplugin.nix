{ lib
, fetchurl
, stdenv
, makeWrapper
, meson
, ninja
, cmake
, gi-docgen
, pkg-config
, glib
, gobject-introspection
, help2man
, gtk4
, lua53Packages
, python312
, python312Packages
}:
stdenv.mkDerivation rec {
  pname = "gplugin";
  version = "0.44.2";

  src = fetchurl {
    url = "mirror://sourceforge/pidgin/gplugin-${version}.tar.xz";
    sha256 = "sha256-rqJE4a3ZYotQ7AQsVM+TgD9Fd/jxQmePCbkf1MCyD3I=";
  };

  nativeBuildInputs = [ meson ninja cmake python312 ];

  buildInputs = [
    gi-docgen
    glib
    gobject-introspection
    gtk4
    help2man
    lua53Packages.lua
    lua53Packages.lgi
    python312
    python312Packages.pygobject3
    python312Packages.meson-python
    pkg-config
  ];
}
