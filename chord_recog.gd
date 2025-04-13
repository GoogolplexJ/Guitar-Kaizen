extends Node

const STARTUP_DELAY = 1.0  # seconds
const PRINT_DELAY = 0.5  # 500ms delay between print outputs
const MIN_DETECTION_MAGNITUDE = 0.04  # Less strict, better sensitivity
const VALID_NOTE_RANGE_HZ = [82, 659]  # E2 to E5
const PERSISTENCE_THRESHOLD = 1  # Detect notes more quickly

var last_detected_notes = []
var detection_persistence = 0

var spectrum_analyzer: AudioEffectSpectrumAnalyzer
var spectrum_instance: AudioEffectSpectrumAnalyzerInstance
var ready_for_detection = false

var print_timer: Timer

func _ready():
	print("initalizing up microphone and analyzer...") #debug comment kei 

	var bus_index = AudioServer.get_bus_index("Master") #gpt
	if bus_index == -1: # bus index gives wrong 
		print(" Audio bus 'Master' not found.")
		return

	spectrum_analyzer = AudioEffectSpectrumAnalyzer.new()
	AudioServer.add_bus_effect(bus_index, spectrum_analyzer)

	var mic = AudioStreamMicrophone.new()
	$AudioStreamPlayer.stream = mic
	$AudioStreamPlayer.play()
	print("Microphone stream started.")

	await get_tree().create_timer(STARTUP_DELAY).timeout
	spectrum_instance = AudioServer.get_bus_effect_instance(bus_index, 0)

	if spectrum_instance:
		ready_for_detection = true
		print("Spectrum analyzer ready.")
	else:
		print(" Failed to initialize spectrum analyzer.")

	print_timer = Timer.new()
	print_timer.wait_time = PRINT_DELAY
	print_timer.one_shot = false
	print_timer.connect("timeout", Callable(self, "_on_print_timer_timeout"))
	add_child(print_timer)
	print_timer.start()

func _process(_delta):
	if not ready_for_detection:
		return

	var detected_notes := []
	var max_magnitude = 0.0
	var average_magnitude = 0.0
	var sample_count = 0

	# First pass: measure overall loudness in range
	for f in range(VALID_NOTE_RANGE_HZ[0], VALID_NOTE_RANGE_HZ[1], 5):
		var mag = spectrum_instance.get_magnitude_for_frequency_range(f - 2, f + 2).length()
		max_magnitude = max(max_magnitude, mag)
		average_magnitude += mag
		sample_count += 1

	if sample_count == 0:
		return

	average_magnitude /= sample_count

	# Loosened ambient noise check for better detection
	if max_magnitude < 0.005: # background  nise
		detection_persistence = 0
		return

	# Second pass: detect strong frequencies
	for f in range(VALID_NOTE_RANGE_HZ[0], VALID_NOTE_RANGE_HZ[1], 1):
		var magnitude = spectrum_instance.get_magnitude_for_frequency_range(f - 2, f + 2).length() # make it outside

		if magnitude > MIN_DETECTION_MAGNITUDE * max_magnitude and magnitude > 0.01: # why is being 
			var note_index = 12 * log(f / 440.0) / log(2) + 30
			var note_number = round(note_index)
			if note_number not in detected_notes:
				detected_notes.append(note_number)

	if detected_notes.size() > 0:
		if detected_notes == last_detected_notes:
			detection_persistence += 1
		else:
			detection_persistence = 1

		last_detected_notes = detected_notes

		if detection_persistence >= PERSISTENCE_THRESHOLD:
			print(" Detected Note Numbers: ", detected_notes)
			print_timer.start()
	else:
		detection_persistence = 0

func _on_print_timer_timeout():
	pass
