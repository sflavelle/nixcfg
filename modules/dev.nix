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
  ];
}
