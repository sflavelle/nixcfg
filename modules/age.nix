{ config
, pkgs
, inputs
, ...
}:
{
  age.secrets = {
    FirelinkShrine = {
      file = ../secrets/FirelinkShrine.age;
      owner = "root";
      group = "root";
    };
  };
}
