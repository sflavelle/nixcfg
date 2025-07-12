{ config
, pkgs
, inputs
, ...
}:
{
  environment.systemPackages = with pkgs; [
    davinci-resolve-studio
  ];
}
