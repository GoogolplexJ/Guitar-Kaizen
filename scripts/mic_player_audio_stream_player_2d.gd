extends AudioStreamPlayer2D

# This function will run when the game starts
func _ready():
	var mic = AudioServer.get_bus_effect(AudioServer.get_bus_index("MicInput"), 0) as AudioEffectCapture
	if mic:
		mic.set_recording_active(true)
		play()  # Start playback so we can process the microphone input
