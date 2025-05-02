 
#code handling song choice options
extends HBoxContainer

@export var selection_box : PackedScene
var songPath = "user://SongFiles/"

#var boxList = []

func _ready() -> void:
	generate_song_options(songPath)

#modified from example code in DirAccess Godot docs
#generate options on the song selection menu from files in SongFiles directory
func generate_song_options(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		#while there are files to look at, add new boxes to the menu and assign their names (and covers if in future)
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				print("Found file: " + file_name)
				if file_name != "noNameSong.dat":
					var newBox = selection_box.instantiate()
					newBox.set_title(file_name)
					#TODO: lock/unlock based off of level/difficulty
					newBox.set_locked(false)
					#TODO: assign cover as well
					newBox.get_button().pressed.connect(_on_pressed.bind(newBox))
					$clipControl/songOptions.add_child(newBox)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
		
func _on_pressed(box):
	print("button pressed:" + box.title)
	MusicVisualizerVariables.song_to_load = box.title
