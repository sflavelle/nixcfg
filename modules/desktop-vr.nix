{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.nixpkgs-xr.nixosModules.nixpkgs-xr
  ];

  environment.systemPackages = with pkgs; [
    wivrn xrizer wlx-overlay-s
    # proton-ge-rtsp-bin
  ];
}