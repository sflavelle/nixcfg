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
    jetbrains.pycharm-community-src vscode-with-extensions
    zed-editor

    yaml-language-server
    python3Packages.python-lsp-server
    bash-language-server
    systemd-language-server
    marksman
  ];
}
