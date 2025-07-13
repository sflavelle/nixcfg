{ config
, pkgs
, inputs
, ...
}:

{
  imports = [
    inputs.nixpkgs-xr.nixosModules.nixpkgs-xr
  ];

  services.wivrn = {
    enable = true;
    openFirewall = true;
    autoStart = true;
    defaultRuntime = true;

  };

  # programs.envision = {
  #   enable = true;
  # };

  systemd.user.services.monado.environment = {
    STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
    WMR_HANDTRACKING = "0";
  };

  environment.systemPackages = with pkgs; [
    wivrn
    xrizer
    wlx-overlay-s
    # proton-ge-rtsp-bin
  ];

  home-manager.users.${config.hostSpec.userName} = {
    xdg.configFile."openvr/openvrpaths.vrpath".text = ''
      {
        "config" :
        [
          "~/.local/share/Steam/config"
        ],
        "external_drivers" : null,
        "jsonid" : "vrpathreg",
        "log" :
        [
          "~/.local/share/Steam/logs"
        ],
        "runtime" :
        [
          "${pkgs.xrizer}/lib/xrizer"
        ],
        "version" : 1
      }
    '';
  };
}
