{ config
, pkgs
, inputs
, ...
}:

{
  environment.systemPackages = with pkgs; [
    (discord.override {
      # withOpenASAR = true;
      withVencord = true;
    })
    element-desktop
    weechat
  ];

  programs.noisetorch.enable = true;
}
