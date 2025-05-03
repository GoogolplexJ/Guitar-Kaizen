extends Node

const NoteComparison := preload("res://scripts/NoteComparison.cs")

# Constants to control detection behavior and limits
const MIN_DETECTION_MAGNITUDE = 0.04  # Relative threshold to filter out weak frequency detections
const VALID_NOTE_RANGE_HZ = [82, 659]  # Frequency range (Hz) between E2 and E5, typical for guitar

# Audio processing components
var spectrum_instance: AudioEffectSpectrumAnalyzerInstance  # Runtime instance for fetching audio frequency data
var ready_for_detection = false  # Flag to determine if audio detection is ready


var compare = load("res://scripts/NoteComparison.cs") as Script  # Reference to NoteComparison

func _ready():
	# Called once when the node enters the scene tree
	print("Initializing microphone and analyzer...")

	# Get the index of the Master audio bus (default bus)
	var bus_index = AudioServer.get_bus_index("Mic")
	if bus_index == -1:
		print("Audio bus 'Mic' not found.")
		return

	# Get the instance of the spectrum analyzer so we can fetch frequency data in real time
	spectrum_instance = AudioServer.get_bus_effect_instance(bus_index, 0)
	if spectrum_instance:
		ready_for_detection = true
		print("Spectrum analyzer ready.")
	else:
		print("Failed to initialize spectrum analyzer.")

func _process(_delta):
	
	# Runs every frame. Used here to continuously analyze audio data.
	if not ready_for_detection:
		return  # Exit early if the analyzer isn't set up yet
	
	var detected_notes := []  # Temporary list for notes detected in this frame

	# Find strong frequency peaks within the valid note range
	for f in range(VALID_NOTE_RANGE_HZ[0], VALID_NOTE_RANGE_HZ[1], 5):
		# Get the average magnitude of a small frequency window centered at f
		var magnitude = spectrum_instance.get_magnitude_for_frequency_range(f - 2, f + 2).length()

		# Check if this frequency is strong enough to be considered a note
		if magnitude > MIN_DETECTION_MAGNITUDE:
			# Convert frequency to an approximate note number
			var note_index = 12 * log(f / 440.0) / log(2) + 30  # 440 Hz is A4
			var note_number = round(note_index)

			# Avoid adding duplicate note numbers
			if note_number not in detected_notes:
				detected_notes.append(note_number)

	# Debugging output: Check what was detected
	#print("Detected notes: " + str(detected_notes))

	# If any notes were detected
	if detected_notes.size() > 0:
		#print("Passing notes to NoteHandler")  # Debug output
		compare.PushDetectedNote(detected_notes, Time.get_ticks_msec())  # Pass detected notes to NoteHandler
