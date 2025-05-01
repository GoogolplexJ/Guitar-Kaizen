#written by: Gabrielle Geppert
#tested by: Gabrielle Geppert
#debugged by: Gabrielle Geppert

extends Node
const Note := preload("res://scripts/Note.cs")

@export var note_visual_scene : PackedScene
#notes spawn in the middle of the staff vertically
var noteSpawnY = MusicVisualizerVariables.staffMiddleY
#for testing, notes spawn in the middle of the screen horizontally
	#will be moved off screen to the right for gameplay
var noteSpawnX = 1920/2

func _ready():
	#create a test note node, parameters: double length, int[] notes, int[] sign
	#all notes in the notes array must have a corresponding sign value
	var testNote := Note.new()
	testNote.length = 1.0/16
	testNote.notes = [3, 40]
	testNote.sign = [1, 0]
	
	#print(testNote.length)
	#print(testNote.notes)
	
	spawn_new_note(testNote)

func spawn_new_note(note : Note): 
	# Create a new instance of the noteVis scene.
	var newNote = note_visual_scene.instantiate()
	newNote.create_note_vis(note)

	# Set the note's position to the proper spot on screen (in the middle of the staff).
	newNote.position.y = noteSpawnY
	newNote.position.x = noteSpawnX
	
	# Spawn the note by adding it to the NoteTest scene.
	$notes.add_child(newNote)

#escape button handling
func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		#make pause screen popup
		SceneSwitcher.SwitchScene("Home")
