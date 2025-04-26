extends Control
class_name NSongMode
@onready var staff := $"staffCreation/staff"
@onready var staffBack := $"staffCreation/staff background"
const Note := preload("res://scripts/Note.cs")
const SongPlayer := preload("res://scripts/SongPlayer.cs")
@export var note_visual_scene : PackedScene
#notes spawn in the middle of the staff vertically
var noteSpawnY = MusicVisualizerVariables.staffMiddleY
#notes spawn off screen to the right for gameplay
var noteSpawnX = 2000

#import song data into variable song from the songSelect scene
var song : SongPlayer
#note visual queue and note length queue(for movement timing)
var noteVisNodes = []
var noteLength = []

#create a note for testing
func create_test_note() -> Note:
	#create a test note node, parameters: double length, int[] notes, int[] sign
	#all notes in the notes array must have a corresponding sign value
	var testNote := Note.new()
	testNote.length = .5
	testNote.notes = [3, 10]
	testNote.sign = [1, 2]
	return testNote

func create_test_song() -> SongPlayer:
	var s := SongPlayer.new()
	s.bpm = 100
	s.noteList = [create_test_note()]
	s.timeSignatureTop = 4
	return s

#return the speed which notes move in pixels/sec
#NOTE: choose a value which gives notes adequate space and player adequate time to prepare
func song_speed() -> float:
	return -song.bpm*1.5 #adjust multiplication value if it ends up being too fast in testing
	
#start delay before notes move, starts the noteTimer on timeout
func _on_start_timer_timeout() -> void:
	$notes/noteTimer.start()
	$notes/startLabel.visible = false

#TODO next note starts moving once the note timer runs out
func _on_note_timer_timeout() -> void:
	#handle note spawning before song starts: code below is for testing
		#var nextNote = create_test_note()
		#var nextNoteVis = spawn_note(nextNote)
	var nextNote = noteVisNodes.pop_back() #grab next note from the note queue
	nextNote.linear_velocity.x = song_speed() #assign linear velocity to note based on song speed (semi arbitrary, since note timing is what actually matters)
	var noteTime = noteLength.pop_back()
	$notes/noteTimer.wait_time = (noteTime * song.timeSignatureTop * 60)/song.bpm #assign note timer's next wait time based on note length and song speed
	
func _ready():
	#adjust staff based on set size
	staff.add_theme_constant_override("margin_bottom", MusicVisualizerVariables.BOTTOM)
	staff.add_theme_constant_override("margin_top", MusicVisualizerVariables.TOP)
	
	staffBack.add_theme_constant_override("margin_bottom", MusicVisualizerVariables.BOTTOM - 20)
	staffBack.add_theme_constant_override("margin_top", MusicVisualizerVariables.TOP - 20)
	
	#generate all note visuals before song starts
	song = create_test_song()
	load_song(song)
	#start the start timer so that there is a delay before the notes move
	$notes/startTimer.start()

func _process(delta) -> void:
	$notes/startLabel.set_text(str(int($notes/startTimer.get_time_left()+1)))

func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		#make pause screen popup
		SceneSwitcher.SwitchScene("Home")

#function for spawning a note into the node tree in the correct position	
func spawn_note(note : Note, barNote : int) -> Node:
	# Create a new instance of the noteVis scene.
	var newNote = note_visual_scene.instantiate()
	newNote.create_note_vis(note, barNote)

	# Set the note's position to the proper spot on screen (in the middle of the staff).
	newNote.position.y = noteSpawnY
	newNote.position.x = noteSpawnX
	
	# Spawn the note by adding it to the NoteTest scene.
	$notes.add_child(newNote)
	return newNote

func load_song(song : SongPlayer):
	#TODO: run through all notes in the song to assign bar note positions (0 if no bar)
	var barNote = []
	#generate note visual nodes for each note in the list and add them to a queue array
		#also add the note's length to a queue array (at the same position) for later use
	var i = 0
	for note in song.noteList:
		noteVisNodes.push_front(spawn_note(note, barNote[i]))
		noteLength.push_front(note.length)
		#TODO: consider handling note bars within this function
		i += 1
		
