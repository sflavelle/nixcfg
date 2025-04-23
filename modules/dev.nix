{
  config,
  pkgs,
  inputs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    gh git
    jetbrains.pycharm-community-src vscode-with-extensions
  ];
}