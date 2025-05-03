extends Node

# Constants to control detection behavior and limits
const STARTUP_DELAY = 1.0  # Time in seconds to wait after startup before analyzing audio
const PRINT_DELAY = 0.5  # Interval in seconds between note print outputs
const MIN_DETECTION_MAGNITUDE = 0.04  # Relative threshold to filter out weak frequency detections
const VALID_NOTE_RANGE_HZ = [82, 659]  # Frequency range (Hz) between E2 and E5, typical for guitar
const PERSISTENCE_THRESHOLD = 1  # Minimum consistent detections needed before confirming a note

# State variables
var last_detected_notes = []  # Cache of the last set of notes detected
var detection_persistence = 0  # Tracks how many frames the same note has been detected for

# Audio processing components
var spectrum_analyzer: AudioEffectSpectrumAnalyzer  # Spectrum analyzer effect object
var spectrum_instance: AudioEffectSpectrumAnalyzerInstance  # Runtime instance for fetching audio frequency data
var ready_for_detection = false  # Flag to determine if audio detection is ready

# Timer used to control printing rate of detected notes
var print_timer: Timer

var note_handler : NoteHandler  # Reference to NoteHandler

func _ready():
	# Called once when the node enters the scene tree
	print("Initializing microphone and analyzer...")

	# Get the index of the Master audio bus (default bus)
	var bus_index = AudioServer.get_bus_index("Mic")
	if bus_index == -1:
		print("Audio bus 'Mic' not found.")
		return

	
	await get_tree().create_timer(STARTUP_DELAY).timeout

	# Get the instance of the spectrum analyzer so we can fetch frequency data in real time
	spectrum_instance = AudioServer.get_bus_effect_instance(bus_index, 0)
	if spectrum_instance:
		ready_for_detection = true
		print("Spectrum analyzer ready.")
	else:
		print("Failed to initialize spectrum analyzer.")

	# Set up a timer to throttle how often notes are printed to the console
	print_timer = Timer.new()
	print_timer.wait_time = PRINT_DELAY
	print_timer.one_shot = false  # Will repeat every PRINT_DELAY seconds
	print_timer.connect("timeout", Callable(self, "_on_print_timer_timeout"))
	add_child(print_timer)
	print_timer.start()

	# Initialize NoteHandler
	note_handler = $NoteHandler  # Ensure NoteHandler is a child node of th

func _process(_delta):
	
	# Runs every frame. Used here to continuously analyze audio data.
	if not ready_for_detection:
		return  # Exit early if the analyzer isn't set up yet
	
	var detected_notes := []  # Temporary list for notes detected in this frame
	var max_magnitude = 0.0  # Highest magnitude found in frequency analysis
	var average_magnitude = 0.0  # Used to estimate overall loudness
	var sample_count = 0  # Counter to compute average magnitude

	# First pass: Measure the loudness in a broader range to determine noise level
	for f in range(VALID_NOTE_RANGE_HZ[0], VALID_NOTE_RANGE_HZ[1], 5):
		var mag = spectrum_instance.get_magnitude_for_frequency_range(f - 2, f + 2).length()
		max_magnitude = max(max_magnitude, mag)
		average_magnitude += mag
		sample_count += 1

	if sample_count == 0:
		return  # Avoid division by zero

	average_magnitude /= sample_count

	# Skip detection if the loudness is too low (likely background noise)
	if max_magnitude < 0.005:
		detection_persistence = 0
		return

	# Second pass: Find strong frequency peaks within the valid note range
	for f in range(VALID_NOTE_RANGE_HZ[0], VALID_NOTE_RANGE_HZ[1], 1):
		# Get the average magnitude of a small frequency window centered at f
		var magnitude = spectrum_instance.get_magnitude_for_frequency_range(f - 2, f + 2).length()

		# Check if this frequency is strong enough to be considered a note
		if magnitude > MIN_DETECTION_MAGNITUDE * max_magnitude and magnitude > 0.01:
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
		# If the same notes are detected as the previous frame, increase persistence
		if detected_notes == last_detected_notes:
			detection_persistence += 1
		else:
			# Otherwise, reset persistence counter
			detection_persistence = 1

		last_detected_notes = detected_notes

		# If persistence meets the threshold, pass the detected notes to the NoteHandler
		if detection_persistence >= PERSISTENCE_THRESHOLD:
			#print("Passing notes to NoteHandler")  # Debug output
			note_handler.ReceiveDetectedNotes(detected_notes, Time.get_ticks_msec())  # Pass detected notes to NoteHandler
			print_timer.start()
	else:
		# Reset persistence if no notes are detected
		detection_persistence = 0

func _on_print_timer_timeout():
	pass
