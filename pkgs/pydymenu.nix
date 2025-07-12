{ lib
, python312Packages
, fetchFromGitHub
,
}:

python312Packages.buildPythonPackage rec {
  pname = "pydymenu";
  version = "0.5.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "gikeymarcia";
    repo = "pydymenu";
    tag = "v${version}";
    hash = "sha256-L/WGmBJMA21VgIKDiFkkN0D2Uq+u0OIGagkj1ee8R48=";
  };

  build-system = [
    python312Packages.setuptools
    python312Packages.wheel
  ];

  dependencies = [
    python312Packages.rich
  ];

  pythonImportsCheck = [
    "pydymenu"
  ];

  meta = {
    description = "A pythonic wrapper interface for fzf, dmenu, and rofi";
    homepage = "https://pypi.org/project/pydymenu/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
  };
}
