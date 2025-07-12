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
}:
stdenv.mkDerivation rec {
  pname = "birb";
  version = "0.4.0";

  src = fetchurl {
    url = "mirror://sourceforge/pidgin/birb-${version}.tar.xz";
    sha256 = "sha256-j8tnVZpr3bMF9ZvlycsS6zXsRaCppuQYS7HfM9ACgIQ=";
  };

  nativeBuildInputs = [ meson ninja cmake ];

  buildInputs = [
    gi-docgen
    glib
    gobject-introspection
    pkg-config
  ];
}
