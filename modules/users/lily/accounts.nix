{ inputs, config, lib, pkgs, ... }:
let
  name = "Simon Flavelle";
  himsettings = {
    envelope.list.datetime-fmt = "%v %r";
    envelope.list.datetime-local-tz = true;
  };
in
{
  calendar = {};
  contact = {};
  email.accounts = {
    "personal" = {
      address = "me@neurario.com";
      flavor = "migadu.com";
      primary = true;
      realName = name;
      himalaya.enable = true;
      himalaya.settings = himsettings;
      thunderbird.enable = true;
    };
    "professional" = {
      address = "simon@simonflavelle.me";
      flavor = "migadu.com";
      realName = name;
      himalaya.enable = true;
      himalaya.settings = himsettings;
      thunderbird.enable = true;
    };
  };
}
