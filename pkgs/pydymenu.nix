{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel,
  rich,
}:

buildPythonPackage rec {
  pname = "pydymenu";
  version = "0.5.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-TAr8DDoKlZu2DSAk9n5Z2wIG30m562ZwIECpfroCLL4=";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    rich
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
