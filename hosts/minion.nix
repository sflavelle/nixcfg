# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../hardware/minion.nix
    ];

  hostSpec = {
    hostName = "minion";
    isPublic = true;
    wirelessInterface = "wlp3s0";
    hasBattery = true;
    isAutoStyled = true;
    wallpaper = pkgs.fetchurl {
      url = "https://w.wallhaven.cc/full/9o/wallhaven-9o59z8.jpg"; # Nature photograph, shaded road through forest
      hash = "sha256-P1jo4hJn6ajsl6EHRBioj8qE5f1Pas6YzzxRSNbcjvw=";
    };
    backlights.monitors = [ "/sys/class/backlight/amdgpu_bl2" ];
  };

  monitors = [
    {
      name = "eDP-1"; # BOE 0x090F Unknown (Built-in Display)
      primary = true;
      width = 1920;
      height = 1080;
      refreshRate = 144;
      x = 0;
      y = 0;
      scale = 1.0;
    }
  ];
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  specialisation = { 
    nvidia.configuration = { 
      # Nvidia Configuration 
      services.xserver.videoDrivers = [ "nvidia" ]; 
      hardware.graphics.enable = true; 
      hardware.nvidia.open = true;
    
      # nvidia-drm.modeset=1 is required for some wayland compositors, e.g. sway 
      hardware.nvidia.modesetting.enable = true; 
    
      hardware.nvidia.prime = { 
        sync.enable = true; 
    
        nvidiaBusId = "PCI:1:0:0"; 
        amdgpuBusId = "PCI:5:0:0"; 
      };
    };
  };

  system.stateVersion = "24.11"; # Did you read the comment?

}
