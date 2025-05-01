extends Node
const Note := preload("res://scripts/Note.cs")

var timeSignatureTop
var timeSignatureBottom
var bpm
var allList = []
var noteList = []
var currentTime
var folder_path := "user://SongFiles/"
var save_name := "noNameSong.dat"
var save_path := folder_path + save_name
var file = FileAccess.open(save_path, FileAccess.READ)

func build_song(songName : String) -> void:
	save_name = "songName"
	save_path = folder_path + save_name + ".dat"
	file = FileAccess.open(save_path, FileAccess.READ)
	var temp = 0
	while file.get_position() < file.get_length():
		temp = file.get_8()
		match temp:
			255: #Note
				build_note()
			254: #BPM
				build_BPM()
			253: #Time Signature
				build_time_signature()
			252: #Bar
				build_bar()
	pass

func build_note() -> void:
	pass

func build_BPM() -> void:
	pass

func build_time_signature() -> void:
	pass

func build_bar() -> void:
	pass
