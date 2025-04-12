{
  config,
  pkgs,
  inputs,
  ...
}:

{
  users.users.splatsune.packages = with pkgs; [
    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })
    element-desktop
  ];
}