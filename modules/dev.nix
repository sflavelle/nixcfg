{
  config,
  pkgs,
  inputs,
  ...
}:

{
  users.users.splatsune.packages = with pkgs; [
    gh git
    jetbrains.pycharm-community-src vscode-with-extensions
  ];
}