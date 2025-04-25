extends Control
class_name NSongMode
@onready var staff := $"staffCreation/staff"
@onready var staffBack := $"staffCreation/staff background"

const Note := preload("res://scripts/Note.cs")
@export var note_visual_scene : PackedScene
#notes spawn in the middle of the staff vertically
var noteSpawnY = MusicVisualizerVariables.staffMiddleY
#notes spawn off screen to the right for gameplay
var noteSpawnX = 2000

#test bpm value
var bpm : float = 100
#create a note for testing
func create_test_note() -> Note:
	#create a test note node, parameters: double length, int[] notes, int[] sign
	#all notes in the notes array must have a corresponding sign value
	var testNote := Note.new()
	testNote.length = .5
	testNote.notes = [3, 10]
	testNote.sign = [1, 2]
	return testNote

#TODO return the speed which notes move in pixels/sec
func song_speed() -> float:
	return -100
	
#start delay before notes move, starts the noteTimer on timeout
func _on_start_timer_timeout() -> void:
	$notes/noteTimer.start()
	$notes/startLabel.visible = false

#TODO next note starts moving once the note timer runs out
func _on_note_timer_timeout() -> void:
	var nextNote = create_test_note()
	var nextNoteVis = spawn_note(nextNote)#TODO grab next note from the note queue
	nextNoteVis.linear_velocity.x = song_speed() #assign linear velocity to note based on song speed
	$notes/noteTimer.wait_time = (nextNote.length * 4 * 60)/bpm #assign note timer's next wait time based on note length and song speed
	
func _ready():
	#adjust staff based on set size
	staff.add_theme_constant_override("margin_bottom", MusicVisualizerVariables.BOTTOM)
	staff.add_theme_constant_override("margin_top", MusicVisualizerVariables.TOP)
	
	staffBack.add_theme_constant_override("margin_bottom", MusicVisualizerVariables.BOTTOM - 20)
	staffBack.add_theme_constant_override("margin_top", MusicVisualizerVariables.TOP - 20)
	
	#generate all note visuals before song starts
	
	#start the start timer so that there is a delay before the notes move
	$notes/startTimer.start()

func _process(delta) -> void:
	$notes/startLabel.set_text(str(int($notes/startTimer.get_time_left()+1)))

func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		#make pause screen popup
		SceneSwitcher.SwitchScene("Home")

#function for spawning a note into the node tree in the correct position	
func spawn_note(note : Note) -> Node:
	# Create a new instance of the noteVis scene.
	var newNote = note_visual_scene.instantiate()
	newNote.create_note_vis(note)

	# Set the note's position to the proper spot on screen (in the middle of the staff).
	newNote.position.y = noteSpawnY
	newNote.position.x = noteSpawnX
	
	# Spawn the note by adding it to the NoteTest scene.
	$notes.add_child(newNote)
	return newNote
