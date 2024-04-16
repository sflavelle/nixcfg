{ lib, buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "freyr-js";
  version = "0.10.3";

  src = fetchFromGitHub {
    owner = "miraclx";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-tAlY0wAjN1rP4MVPl40N/rgMQH08jD0XKBVRGFWAK70=";
  };

  npmDepsHash = "sha256-tVOOT3abo31s6PJVfeH1WyH7ruu3sXBas7SLmTWQsbA=";

  NODE_OPTIONS = "--openssl-legacy-provider";

  meta = with lib; {
    description = "A modern web UI for various torrent clients with a Node.js backend and React frontend";
    homepage = "https://flood.js.org";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ winter ];
  };
}
