{
  config,
  pkgs,
  inputs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    gh git
    nixd nil
    jetbrains.pycharm-community-src vscode-fhs
    zed-editor helix
    pgadmin4-desktopmode dbeaver-bin

    yaml-language-server
    python3Packages.python-lsp-server
    bash-language-server
    systemd-language-server
    marksman

    jq yq
  ];

  environment.variables = {
    EDITOR = "hx";
  };
}
