{ lib
, stdenv
, fetchFromGitHub
, obs-studio
, cmake
}:

stdenv.mkDerivation rec {
  pname = "obs-advanced-masks";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "FiniteSingularity";
    repo = "obs-advanced-masks";
    rev = "refs/tags/v${version}";
    hash = "sha256-NtmOWKk3eZeRa3TvclZpg4sj8lbOoY8hUhxs1z6kEW4=";
  };

  buildInputs = [
    obs-studio
  ];

  nativeBuildInputs = [
    cmake
  ];

  postInstall = ''
    rm -rf "$out/share"
    mkdir -p "$out/share/obs"
    mv "$out/data/obs-plugins" "$out/share/obs"
    rm -rf "$out/obs-plugins" "$out/data"
  '';

  meta = with lib; {
    description = "An open-source project designed to expand the masking functionalities within OBS Studio";
    homepage = "https://github.com/FiniteSingularity/obs-advanced-masks";
    license = licenses.gpl2Only;
    mainProgram = "obs-advanced-masks";
    platforms = platforms.linux;
  };
}
