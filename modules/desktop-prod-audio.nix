{ config
, pkgs
, inputs
, ...
}:
{
  environment.systemPackages = with pkgs; [
    bitwig-studio5-latest
    reaper
    ffmpeg-full

    demucs

    # VST plugins
    yabridge
    yabridgectl
    airwindows
    oxefmsynth
    zam-plugins
    lsp-plugins
    # chow-tape-model # webkitgtk nonsense
    decent-sampler

    # papu
    # paulxstretch
    # neuralnote

  ];
}
