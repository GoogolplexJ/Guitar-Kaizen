#written by: Gabrielle Geppert
#tested by: Gabrielle Geppert
#debugged by: Gabrielle Geppert

extends Control
class_name NSongMode
@onready var staff := $"staffCreation/staff"
@onready var staffBack := $"staffCreation/staff background"
@onready var noteTimer := $notes/noteTimer
@onready var colLine := $notes/lineCollision
@onready var timingLabel := $feedback/MarginContainer/HBoxContainer/timing
@onready var missedLabel := $feedback/MarginContainer/HBoxContainer/missed
@onready var perfectLabel := $feedback/MarginContainer/HBoxContainer/perfect
@onready var pitchLabel := $feedback/MarginContainer/HBoxContainer/pitch
const Note := preload("res://scripts/Note.cs")
const SongPlayer := preload("res://scripts/song_player.gd")
const NoteComparison := preload("res://scripts/NoteComparison.cs")
@export var note_visual_scene : PackedScene
@export var song_mode_controller_scene : PackedScene
@export var test_song : PackedScene
var songName := ""

var compare : NoteComparison
var song : SongPlayer
var songModeControl
#start delay before notes move, starts the noteTimer on timeout
func _on_start_timer_timeout() -> void:
	noteTimer.start()
	#set note timing based on first note in sequence
	noteTimer.wait_time = songModeControl.note_timing_calc(songModeControl.noteLength.pop_back())
	$notes/startLabel.visible = false

#next note starts moving once the note timer runs out
func _on_note_timer_timeout() -> void:
	#handle note spawning before song starts: code below is for testing
		#var nextNote = create_test_note()
		#var nextNoteVis = spawn_note(nextNote)
	var nextNote = songModeControl.noteVisNodes.pop_back() #grab next note from the note queue
	if !nextNote:
		noteTimer.paused = true
		return
	nextNote.linear_velocity.x = songModeControl.song_speed() #assign linear velocity to note based on song speed (semi arbitrary, since note timing is what actually matters)
	#set timer for next note
	noteTimer.wait_time = songModeControl.note_timing_calc(songModeControl.noteLength.pop_back())
	
#note collision detection with the end line
func _on_line_collision_body_entered(body: Node2D) -> void:
	#print("notepassed")
	song.noteList[0].timePlayed = Time.get_ticks_msec()
	#compare played note(s) to ideal note(s)
	compare.AddIdealNote(song.noteList.pop_front())
	$notes/lineCollision/ColorRect.color = Color(0, 1, 1, 1)
	#TODO: collect timing and pitch score
	#NOTE: feedback currently randomized for testing
	#display_feedback(randi() % 4 + 1, randi() % 4 + 1)

func _on_line_collision_body_exited(body: Node2D) -> void:
	#print("notepassed")
	#song.noteList[0].timePlayed = Time.get_ticks_msec()
	#compare.AddIdealNote(song.noteList.pop_front())
	$notes/lineCollision/ColorRect.color = Color(.35, .32, .7, 1)
	pass
	
	
func _ready():
	compare = NoteComparison.new() # creates a note comparison instance
	compare.SetFeedback.connect(_display_feedback) # connects the note comparison signal to call _on_set_feedback
	initialize_analizer()
	initialize_visuals()

# starts visuals and the timer before notes begin
func initialize_visuals():
	#adjust staff based on set size
	staff.add_theme_constant_override("margin_bottom", MusicVisualizerVariables.BOTTOM)
	staff.add_theme_constant_override("margin_top", MusicVisualizerVariables.TOP)
	
	staffBack.add_theme_constant_override("margin_bottom", MusicVisualizerVariables.BOTTOM - 20)
	staffBack.add_theme_constant_override("margin_top", MusicVisualizerVariables.TOP - 20)
	
	colLine.position.y = MusicVisualizerVariables.staffMiddleY
	colLine.position.x = MusicVisualizerVariables.LIMIT_LINE
	
	songModeControl = song_mode_controller_scene.instantiate()
	$notes.add_child(songModeControl)
	#generate all note visuals before song starts
	#var test = test_song.instantiate()
	song = SongPlayer.new()
	song.build_song(MusicVisualizerVariables.song_to_load)
	songModeControl.song = song
	songModeControl.load_song()
	#start the start timer so that there is a delay before the notes move
	$notes/startTimer.start()


func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		#make pause screen popup
		SceneSwitcher.SwitchScene("Home")

func _set_song(sN : String) -> void:
	songName = sN

#control rudamentary real time feedback labels
func _display_feedback(timing : int, pitch : int):
	#turn off all labels that may have been on
	timingLabel.visible = false
	missedLabel.visible = false
	perfectLabel.visible = false
	pitchLabel.visible = false
	#if timing is 1, note was missed
	if timing == 1:
		missedLabel.visible = true
		return
	elif (timing == 5)&&(pitch == 5):
		perfectLabel.visible = true
		return
	else:
		match timing:
			2: timingLabel.text = "TOO SLOW"
			3: timingLabel.text = "ALMOST"
			4: timingLabel.text = "GOOD TIMING!"
			5: timingLabel.text = "PERFECT TIMING!"
		match pitch:
			5: pitchLabel.text = "PERFECT NOTE!"
			4: pitchLabel.text = "GOOD NOTE!"
			_: pitchLabel.text = "OFF NOTE"
		pitchLabel.visible = true
		timingLabel.visible = true



# Constants to control detection behavior and limits
const MIN_DETECTION_MAGNITUDE = 0.04  # Relative threshold to filter out weak frequency detections
const VALID_NOTE_RANGE_HZ = [82, 659]  # Frequency range (Hz) between E2 and E5, typical for guitar

# Audio processing components
var spectrum_instance: AudioEffectSpectrumAnalyzerInstance  # Runtime instance for fetching audio frequency data
var ready_for_detection = false  # Flag to determine if audio detection is ready

# creates instances to be ready for audio processing
func initialize_analizer():
	#print("Initializing microphone and analyzer...")

	# Get the index of the Master audio bus (default bus)
	var bus_index = AudioServer.get_bus_index("Mic")
	if bus_index == -1:
		print("Audio bus 'Mic' not found.")
		return

	# Get the instance of the spectrum analyzer so we can fetch frequency data in real time
	spectrum_instance = AudioServer.get_bus_effect_instance(bus_index, 0)
	if spectrum_instance:
		ready_for_detection = true
	#	print("Spectrum analyzer ready.")
	else:
		print("Failed to initialize spectrum analyzer.")


func _process(_delta):
	
	$notes/startLabel.set_text(str(int($notes/startTimer.get_time_left()+1)))
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
