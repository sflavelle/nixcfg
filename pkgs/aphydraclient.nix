{
  lib,
  stdenv,
  fetchFromGitHub,
  buildDotnetModule,
}:

buildDotnetModule rec {
  pname = "hydratextclient";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "SWCreeperKing";
    repo = "HydraTextClient";
    tag = "v.${version}";
    hash = "sha256-X8lTNnMci7bzw5AIENV23qKAGlpBg0nb9QaS/wjzRqY=";
  };

  projectFile = "ArchipelagoMultiTextClient.csproj";
  nugetDeps = ./aphydraclient-deps.nix;

  meta = {
    homepage = "https://github.com/SWCreeperKing/HydraTextClient";
    description = "Archipelago Text Client that connects to multiple slots at once";
    license = [ lib.licenses.unfree ];
    platforms = lib.platforms.all;
    # maintainers = [ lib.maintainers.sflavelle ];
  };
}
