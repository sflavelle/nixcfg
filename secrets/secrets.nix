let
  lily-snatcher = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ72u+rxADmeVHX0xyj9CslY9f6cwu2zu8Qy022mfitf";
  lily-badgeseller = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBmOUi6fw2ut6hfoaemCHSm8kfX3QGUSuCS3xKQ6iOOx";
  lily-minion = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICc1Y9pDbnVAOCTNyW6jTvNm8mKzloYLZPvrNAPJwMBD";
  lily-puppetmaster = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF3wyordxC55XPMdP5dn17oMwhUYrR8jNaMR1Hk8aaFq";
  lily-empress = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJOnTMae/dpdLFH1tfwEIhDO1pP1/4NAItMKkZNF2OVI";
  lily-dweller = null;
  lily = [ lily-snatcher lily-badgeseller lily-minion lily-puppetmaster lily-empress ];

  snatcher = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMLW334rZXE0+UID24q+upEDpQiXjyefvzse0fFXLasL";
  badgeseller = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMaimQA4Fftnv6+114hTseYVItxuylpr0u1gqIY+3aGZ";
  minion = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEWkhDndQ6oNaLYL9eKu1jIqtY5U+KozaoCGzjQRSvMn";
  puppetmaster = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJZYyueNuVtjDAO8OEnAY524lH7L09CzcZmc/LzgxRVN";
  dweller = null;
  servers = [ puppetmaster ];
  desktops = [ snatcher ];
  laptops = [ badgeseller minion ];
  all-systems = servers ++ desktops ++ laptops;

in
{
  "FirelinkShrine.age".publicKeys = lily ++ laptops;
  "GitHubNix.age".publicKeys = lily ++ all-systems;
}
