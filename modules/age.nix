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
    nix-access-tokens-github = {
      file = ../secrets/GitHubNix.age;
    };
    splatsune-tgcirc = {
      file = ../secrets/Splatsune-TGCIRC.age;
      mode = "775";
      owner = config.hostSpec.userName;
      group = config.hostSpec.userName;
    };
  };

  nix.extraOptions = ''
    !include ${config.age.secrets.nix-access-tokens-github.path}
  '';
}
