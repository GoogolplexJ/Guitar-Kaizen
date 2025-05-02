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

# BPM's and how many notes are part of the bpm
var BPMs = []
var BPMNotes = []

var barNote : Array[int]

var song : SongPlayer


#return the speed which notes move in pixels/sec
#NOTE: choose a value which gives notes adequate space and player adequate time to prepare
func song_speed() -> float:
	return -BPMs[0]*3.5 #adjust multiplication value if it ends up being too fast in testing
	
func note_timing_calc(noteTime : float) -> float:
	return (noteTime * song.timeSignatureBottom * 60)/BPMs[0]
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


func load_song():
	#TODO: run through all notes in the song to assign bar note positions (0 if no bar)
	barNote = []
	for i in song.allList.size():
		match song.allList[i]:
			"N":
				i+=1
				barNote.push_front(0)
				load_note(song.allList[i])
			"B":
				i+=1
				load_BPM(song.allList[i])
			"T":
				i+=2
				load_time_signature(song.allList[i-1], song.allList[i])
			"I":
				i+=1
				load_Bar(song.allList[i], i)
				i += song.allList[i]
	noteLength.push_front(1)

func load_note(note : Note) -> void:
	noteVisNodes.push_front(spawn_note(note, barNote.pop_back()))
	noteLength.push_front(note.length)

func load_BPM(bpm : int) -> void:
	BPMs.push_front(bpm)
func load_time_signature(timeTop : int, timeBottom: int) -> void:
	song.timeSignatureTop = timeTop
	song.timeSignatureBottom = timeBottom


# loads notes with the barNote list set to the furthest value from the center
func load_Bar(barLength : int, index : int) -> void:
	var list = []
	for i in barLength:
		list.append(song.allList[index + i*2])
	var minMax = find_min_max(list)
	for i in list:
		barNote.push_front(minMax)
		load_note(list[i])

# finds the note furthest from the center
func find_min_max(list : Array[Note]) -> int:
	var max = 20
	var min = 21
	for note in list:
		if(note.notes[note.notes.size() - 1] > max):
			max = note.notes[note.notes.size() - 1]
		if(note.notes[0] < min):
			min = note.notes[0]
	max = max - 20
	min = 20 - min
	if(min >= max):
		return min
	else:
		return max

#TODO: change barInfo functions when song reading is implemented
func oldload_song():
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
