{ config
, pkgs
, inputs
, ...
}:

{
  environment.systemPackages = with pkgs; [
    gh
    git
    nixd
    nil
    helix
    pgadmin4-desktopmode

    yaml-language-server
    python3Packages.python-lsp-server
    bash-language-server
    systemd-language-server
    marksman

    jq
    yq
  ];

  environment.variables = {
    EDITOR = "hx";
  };
}
