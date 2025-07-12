{ config
, pkgs
, inputs
, lib
, ...
}:

{
  services.postgresql = {
    enable = true;
    ensureDatabases = [
      "splatsunebots"
    ];
  };

}
