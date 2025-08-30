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
  };

  nix.extraOptions = ''
    !include ${config.age.secrets.nix-access-tokens-github.path}
  '';
}
