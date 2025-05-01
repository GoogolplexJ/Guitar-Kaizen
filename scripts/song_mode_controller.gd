#written by: Gabrielle Geppert
#tested by: Gabrielle Geppert
#debugged by: Gabrielle Geppert

extends Node2D

const Note := preload("res://scripts/Note.cs")
const SongPlayer := preload("res://scripts/song_player.gd")
@export var note_visual_scene : PackedScene

#notes spawn in the middle of the staff vertically
var noteSpawnY = MusicVisualizerVariables.staffMiddleY
#notes spawn off screen to the right for gameplay
var noteSpawnX = 2000

#note visual queue and note length queue(for movement timing)
var noteVisNodes = []
var noteLength = []

var song : SongPlayer

#return the speed which notes move in pixels/sec
#NOTE: choose a value which gives notes adequate space and player adequate time to prepare
func song_speed() -> float:
	return -song.bpm*3.5 #adjust multiplication value if it ends up being too fast in testing
	
func note_timing_calc(noteTime : float) -> float:
	return (noteTime * song.timeSignatureTop * 60)/song.bpm 
	#assign note timer's next wait time based on note length and song speed
	
#function for spawning a note into the node tree in the correct position	
func spawn_note(note : Note, barNote : int) -> Node:
	# Create a new instance of the noteVis scene.
	var newNote = note_visual_scene.instantiate()
	newNote.create_note_vis(note, barNote)

	# Set the note's position to the proper spot on screen (in the middle of the staff).
	newNote.position.y = noteSpawnY
	newNote.position.x = noteSpawnX
	
	# Spawn the note by adding it to the NoteTest scene.
	add_child(newNote)
	return newNote

#TODO: change barInfo functions when song reading is implemented
func load_song():
	#TODO: run through all notes in the song to assign bar note positions (0 if no bar)
	var barNote : Array[int]
	#generate note visual nodes for each note in the list and add them to a queue array
		#also add the note's length to a queue array (at the same position) for later use
	for note in song.noteList:
		barNote.push_front(0)
		noteVisNodes.push_front(spawn_note(note, barNote.pop_back()))
		noteLength.push_front(note.length)
		#TODO: consider handling note bars within this function
	noteLength.push_front(1)
