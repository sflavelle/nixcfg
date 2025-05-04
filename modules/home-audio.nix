{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  environment.systemPackages = with pkgs; [
  ];

  services.snapserver = {
    enable = true;
    tcp.enable = true;
    tcp.listenAddress = "0.0.0.0";
    openFirewall = true;
    listenAddress = "0.0.0.0";
    buffer = 1000;
    streamBuffer = 20;
    streams = {
      "MPD (Lily)" = {
        type = "pipe";
        location = "/run/snapserver/mpd-lily";
        sampleFormat = "48000:16:2";
        codec = "pcm";
      };
      "Soundscapes" = {
        type = "process";
        location = "${pkgs.mpv}/bin/mpv";
        sampleFormat = "48000:16:2";
        query.logStderr = "true";
        query.params = lib.strings.concatStringsSep " " [
          "/mnt/media/soundscapes"
          "--shuffle --volume=0.5"
          "--no-terminal --audio-display=no --audio-channels=stereo"
          "--audio-samplerate=48000 --audio-format=s16"
          "--af=lavfi=[dynaudnorm=f=75:g=201:p=0.55:s=10]"
          "--ao=pcm --ao-pcm-file=/dev/stdout"
        ];
      };
      "ABC NewsRadio" = {
        type = "process";
        location = "${pkgs.mpv}/bin/mpv";
        sampleFormat = "48000:16:2";
        query.logStderr = "true";
        query.params = lib.strings.concatStringsSep " " [
          "https://mediaserviceslive.akamaized.net/hls/live/2038311/newsradio/index.m3u8"
          "--shuffle --volume=1.0"
          "--no-terminal --audio-display=no --audio-channels=stereo"
          "--audio-samplerate=48000 --audio-format=s16"
          "--af=lavfi=[dynaudnorm=f=75:g=201:p=0.55:s=10]"
          "--ao=pcm --ao-pcm-file=/dev/stdout"
        ];
      };
    };
  };
}
