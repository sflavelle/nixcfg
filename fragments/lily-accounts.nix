{ home-manager, config, pkgs, lib, inputs, ... }:
    {
        calendar.accounts = {
            icloud = {
                
            };
        };
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
                   realName = "Simon Flavelle";
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
               };
           };
        };
    }
