{
  config,
  pkgs,
  inputs,
  ...
}:
{
  age.secrets = {
    FirelinkShrine.file = ../secrets/FirelinkShrine.age;
  };
}