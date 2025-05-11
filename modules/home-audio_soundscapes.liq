

enable_autocue_metadata()

audio = playlist("/mnt/media/soundscapes", reload=1800)

stream = amplify(1.,override="liq_amplify",audio)
stream = crossfade(stream)
stream = mksafe(stream)

output.external(%wav(stereo=true, channels=2, samplerate=48000, samplesize=16, header=false), "cat > /run/snapserver/soundscapes", stream)
