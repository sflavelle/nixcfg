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
    zed-editor

    yaml-language-server
    python3Packages.python-lsp-server
    bash-language-server
    systemd-language-server
    marksman
  ];
}
