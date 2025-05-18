
audio = playlist("/mnt/media/soundscapes", reload=1800)

stream = normalize(up=30., lookahead=1., audio)

stream = crossfade(duration=30., stream)
stream = mksafe(stream)

output.external(%wav(stereo=true, channels=2, samplerate=48000, samplesize=16, header=false), "cat > /run/snapserver/soundscapes", stream)
