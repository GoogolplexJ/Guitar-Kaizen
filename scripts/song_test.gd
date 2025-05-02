#written by: Gabrielle Geppert
#tested by: Gabrielle Geppert
#debugged by: Gabrielle Geppert

extends Node2D

const Note := preload("res://scripts/Note.cs")
const SongPlayer := preload("res://scripts/song_player.gd")

#testing code
#create a note object for testing
func test_note(l : float, n : Array[int], s : Array[int]) -> Note:
	#create a test note node, parameters: double length, int[] notes, int[] sign
	#all notes in the notes array must have a corresponding sign value
	var testNote := Note.new()
	testNote.length = l
	testNote.notes = n
	testNote.sign = s
	return testNote
#create a song object for testing
func create_test_song() -> SongPlayer:
	var s := SongPlayer.new()
	s.bpm = 100
	#hot cross buns :)
	s.noteList = [test_note(0.25, [20], [0]), test_note(0.25, [18], [0]), test_note(0.5, [16], [0]), test_note(0.25, [20], [0]), test_note(0.25, [18], [0]), test_note(0.5, [16], [0]), test_note(0.125, [16], [0]), test_note(0.125, [16], [0]), test_note(0.125, [16], [0]), test_note(0.125, [16], [0]), test_note(0.125, [18], [0]), test_note(0.125, [18], [0]),test_note(0.125, [18], [0]), test_note(0.125, [18], [0]), test_note(0.25, [20], [0]), test_note(0.25, [18], [0]), test_note(0.5, [16], [0])]
	s.timeSignatureTop = 4
	return s
func test_song_bar() -> Array[int]:
	#integer list corresponding to the start and length of bars in hot cross buns test song
	#0 = note is not start of bar
	#other values indicate that the note is the start of a bar along with how long the bar is
	var hocrossBum : Array[int]
	for i in 6:
		hocrossBum.push_back(0)
	hocrossBum.push_back(4)
	for i in 3:
		hocrossBum.push_back(0)
	hocrossBum.push_back(4)
	for i in 6:
		hocrossBum.push_back(0)
	return hocrossBum
