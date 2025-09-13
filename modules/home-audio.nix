{ config
, pkgs
, inputs
, lib
, ...
}:

{
  environment.systemPackages = with pkgs; [
  ];

  services.mympd = {
    enable = true;
    settings.http_port = 6670;
    openFirewall = true;
  };

  services.liquidsoap.streams = {
    soundscapes = ./home-audio_soundscapes.liq;
  };

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
        type = "pipe";
        location = "/run/snapserver/soundscapes";
        sampleFormat = "48000:16:2";
        codec = "pcm";
      };
      "Shairplay (Lily)" = {
        type = "airplay";
        sampleFormat = "48000:16:2";
        location = "${pkgs.shairport-sync}/bin/shairport-sync";
        query.port = "6000";
      };
      "Shairplay (Juno)" = {
        type = "airplay";
        sampleFormat = "48000:16:2";
        location = "${pkgs.shairport-sync}/bin/shairport-sync";
        query.port = "6001";
      };
      # };
      # "ABC NewsRadio" = {
      #   type = "process";
      #   location = "${pkgs.mpv}/bin/mpv";
      #   sampleFormat = "48000:16:2";
      #   query.logStderr = "true";
      #   query.params = lib.strings.concatStringsSep " " [
      #     "https://mediaserviceslive.akamaized.net/hls/live/2038311/newsradio/index.m3u8"
      #     "--shuffle --volume=1.0"
      #     "--no-terminal --audio-display=no --audio-channels=stereo"
      #     "--audio-samplerate=48000 --audio-format=s16"
      #     "--af=lavfi=[dynaudnorm=f=75:g=201:p=0.55:s=10]"
      #     "--ao=pcm --ao-pcm-file=/dev/stdout"
      #   ];
      # };
    };
  };
}
