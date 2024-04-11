{ home-manager, config, pkgs, lib, inputs, ... }:
let
    name = "Simon Flavelle";
    graphical = config.services.xserver.enable;
in
    {
        email = {
           accounts = {
               icloud = {
                   userName = "neurario@icloud.com";
                   address = "neurario@icloud.com";
                   aliases = [
                       "me@neuario.com"
                       "simon@simonflavelle.me"
                       "simonsayslps@icloud.com"
                       "simon.flavelle@icloud.com"
                   ];
                   passwordCommand = "cat /run/secrets/passwords/icloud";
                   realName = name;
                   primary = true;
                   imap = {
                       host = "imap.mail.me.com";
                       port = 993;
                   };
                   himalaya.enable = true;
                   astroid.enable = true;
                   msmtp.enable = true;
                   offlineimap = {
                       enable = true;
                   };
                   thunderbird.enable = graphical;
               };
               neuraria = {
                flavor = "gmail.com";
                address = "neuraria@gmail.com";
                realName = name;
                passwordCommand = "cat /run/secrets/passwords/gmail/neuraria";
                thunderbird.enable = graphical;
               };
               simonsayslps = {
                flavor = "gmail.com";
                address = "simonsayslps@gmail.com";
                realName = name;
                passwordCommand = "cat /run/secrets/passwords/gmail/simonsayslps";
                thunderbird.enable = graphical;
               };
               simonflavelle = {
                flavor = "gmail.com";
                address = "simon.flavelle@gmail.com";
                realName = name;
                passwordCommand = "cat /run/secrets/passwords/gmail/simonf";
                thunderbird.enable = graphical;
               };
           };
        };
    }
