{
  stdenv,
  callPackage,
  fetchhg,
  meson,
  ninja,
  makeWrapper,
  aspell,
  avahi,
  birb,
  cacert,
  cmake,
  dbus,
  dbus-glib,
  farstream,
  gettext,
  gi-docgen,
  gst_all_1,
  gtk4,
  gtk2-x11,
  gobject-introspection,
  intltool,
  json-glib,
  kdePackages,
  lib,
  libadwaita,
  libspelling,
  libICE,
  libSM,
  libXScrnSaver,
  libXext,
  libgcrypt,
  libgnt,
  libidn,
  libsecret,
  libsoup_3,
  libstartup_notification,
  libxml2,
  ncurses,
  nspr,
  nss,
  perlPackages,
  pkg-config,
  python3,
  pidgin,
  plugins ? [ ],
  qt6,
  seagull,
  sqlite,
  withOpenssl ? false,
  openssl,
  withGnutls ? false,
  gnutls,
  withCyrus_sasl ? true,
  cyrus_sasl,
  pidginPackages,
}:

# FIXME: clean the mess around choosing the SSL library (nss by default)

let
  unwrapped = stdenv.mkDerivation rec {
    pname = "pidgin3";
    version = "2.92.1";

    src = fetchhg {
      url = "https://keep.imfreedom.org/pidgin/pidgin";
      rev = "v${version}";
      sha256 = "sha256-xP4aEPnJVxnNMbjjjsXZuuVYQPCDAgcvGgKn5nn8M60=";
    };

    nativeBuildInputs = [
      meson ninja cmake
      makeWrapper
      intltool
    ];

    dontWrapQtApps = true;

    env.NIX_CFLAGS_COMPILE = "-I${gst_all_1.gst-plugins-base.dev}/include/gstreamer-1.0";

    buildInputs =
      let
        python-with-dbus = python3.withPackages (pp: with pp; [ dbus-python ]);
      in
      [
        aspell
        avahi
        birb
        cyrus_sasl
        dbus
        dbus-glib
        gi-docgen
        gobject-introspection
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gstreamer
        json-glib
        kdePackages.kwallet
        libICE
        libSM
        libXScrnSaver
        libXext
        libgnt
        libidn
        libsecret
        libsoup_3
        libstartup_notification
        libxml2
        ncurses # optional: build finch - the console UI
        nspr
        nss
        python-with-dbus
        qt6.qtbase
        seagull
        sqlite
      ]
      ++ lib.optional withOpenssl openssl
      ++ lib.optionals withGnutls [
        gnutls
        libgcrypt
      ]
      ++ lib.optionals stdenv.hostPlatform.isLinux [
        gtk4
        libspelling
        libadwaita
        farstream
      ]
      ++ lib.optional stdenv.hostPlatform.isDarwin gtk2-x11;

    propagatedBuildInputs =
      [
        pkg-config
        gettext
      ]
      ++ (with perlPackages; [
        perl
        XMLParser
      ])
      ++ lib.optional stdenv.hostPlatform.isLinux gtk4
      ++ lib.optional stdenv.hostPlatform.isDarwin gtk2-x11;

    # patches = [
    #   ./add-search-path.patch
    #   ./pidgin-makefile.patch
    # ];

    configureFlags =
      [
        "--with-nspr-includes=${nspr.dev}/include/nspr"
        "--with-nspr-libs=${nspr.out}/lib"
        "--with-nss-includes=${nss.dev}/include/nss"
        "--with-nss-libs=${nss.out}/lib"
        "--with-ncurses-headers=${ncurses.dev}/include"
        "--with-system-ssl-certs=${cacert}/etc/ssl/certs"
        "--disable-meanwhile"
        "--disable-nm"
        "--disable-tcl"
        "--disable-gevolution"
      ]
      ++ lib.optionals withCyrus_sasl [ "--enable-cyrus-sasl=yes" ]
      ++ lib.optionals withGnutls [
        "--enable-gnutls=yes"
        "--enable-nss=no"
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        "--disable-gtkspell"
        "--disable-vv"
      ]
      ++ lib.optionals stdenv.cc.isClang [ "CFLAGS=-Wno-error=int-conversion" ];

    enableParallelBuilding = true;

    postInstall = ''
      wrapProgram $out/bin/pidgin \
        --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0"
    '';

    doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
    # In particular, this detects missing python imports in some of the tools.
    postFixup =
      let
        # TODO: python is a script, so it doesn't work as interpreter on darwin
        binsToTest = lib.optionalString stdenv.hostPlatform.isLinux "purple-remote," + "pidgin,finch";
      in
      lib.optionalString doInstallCheck ''
        for f in "''${!outputBin}"/bin/{${binsToTest}}; do
          echo "Testing: $f --help"
          "$f" --help
        done
      '';

    passthru = {
      makePluginPath = lib.makeSearchPathOutput "lib" "lib/purple-${lib.versions.major version}";
      withPlugins =
        pluginfn:
        callPackage ./wrapper.nix {
          plugins = pluginfn pidginPackages;
          pidgin = unwrapped;
        };
    };

    meta = {
      description = "Multi-protocol instant messaging client";
      mainProgram = "pidgin";
      homepage = "https://pidgin.im/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.unix;
      maintainers = [ lib.maintainers.lucasew ];
    };
  };

in
if plugins == [ ] then unwrapped else unwrapped.withPlugins (_: plugins)