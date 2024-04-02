# CURRENTLY NON-FUNCTIONAL,
# DOES NOT PATCH YET
#
# For running on NixOS
# steam-run works in the meantime

{ stdenv, lib
, fetchurl
, openssl
, libgcc
, libz
, xorg
, libGL
, lttng-ust_2_12
, autoPatchelfHook
, makeDesktopItem
, makeWrapper
, enabledPlando ? "bosses, items, connections, text"
}:

stdenv.mkDerivation rec {
    pname = "archipelago-bin";
    version = "0.4.5";

    src = fetchurl {
        url = "https://github.com/ArchipelagoMW/Archipelago/releases/download/${version}/Archipelago_${version}_linux-x86_64.tar.gz";
        hash = "sha256-jAnohmEM48wwVQ8UJJgW27m1HFNVVfQpsSFV/GzS7WY=";
    };

    nativeBuildInputs = [ autoPatchelfHook makeWrapper ];

    buildInputs = [
        openssl
        libgcc.lib
        libz
        glib
        lttng-ust_2_12
        xorg.libX11
        xorg.libXrender
        xorg.lib
    ];

    sourceRoot = "./Archipelago";

    dontConfigure = true;
    dontBuild = true;

    desktopItems = [
        (makeDesktopItem {
            name = "archipelago-launcher";
            desktopName = "Archipelago (Launcher)";
            comment = "Play randomized video games";
            exec = "ArchipelagoLauncher";
#            icon = "$out/lib/share/archipelago/data/icon.png";
        })
    ];

    installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/archipelago/lib
#    mkdir -p /var/lib/archipelago/{worlds,Players}
#    ln -s /var/lib/archipelago/worlds $out/opt/archipelago/lib/worlds
#    ln -s /var/lib/archipelago/Players $out/opt/archipelago/Players
    cp -rv ./* $out/opt/archipelago

    runHook postInstall
    '';

    postFixup = ''

    makeWrapper ArchipelagoLauncher $out/bin/ArchipelagoLauncher --chdir $out/opt/archipelago
    makeWrapper ArchipelagoGenerate $out/bin/ArchipelagoGenerate --chdir $out/opt/archipelago --add-flags "--player_files_path . --outputpath ."
    makeWrapper ArchipelagoServer $out/bin/ArchipelagoServer --chdir $out/opt/archipelago

		'';
}
