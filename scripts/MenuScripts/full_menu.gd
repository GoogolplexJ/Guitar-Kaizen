 
#code handling song choice options
extends Control

@export var selection_box : PackedScene
var songPath = "user://SongFiles/"

signal box_selected(value)
signal pos_selected(value)
var current_selection = null
var boxWidth = 380

func _ready() -> void:
	generate_song_options(songPath)

#modified from example code in DirAccess Godot docs
#generate options on the song selection menu from files in SongFiles directory
func generate_song_options(path):
	var dir = DirAccess.open(path)
	var count = 0
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
					#create new box instance from file
					var newBox = selection_box.instantiate()
					#set parameters of box based off of file
					newBox.set_title(file_name)
					#TODO: lock/unlock based off of level/difficulty
					newBox.set_locked(false)
					#TODO: assign cover as well
					newBox.set_pos(count)
					count+=1
					#if there is not a current selection defined already, add one
					if !current_selection:
						current_selection = newBox
						box_selected.emit(newBox.song_title.rstrip(".dat"))
						var currentPos = newBox.global_position.x
						$songOptions.position.x = -currentPos + boxWidth*2
					#connect box to button signal
					newBox.get_button().pressed.connect(_on_pressed.bind(newBox))
					$songOptions.add_child(newBox)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
		
func _on_pressed(box):
	#if button has already been selected once before, call second press function to go into the song
	if current_selection != box:
		first_press(box)
		label_update(box)
	else:
		second_press(box)
	
#select song to be played:
func first_press(box):
	#send a signal to the songSelection controller to update songTitle label
	pos_selected.emit(box.get_pos())
	#move the selected song to the middle of the screen (and probably change its appearance)
		#get current global position of the selection box
		#change position of songOptions so that selection box is in the middle of the screen
			#songOptions = -currentPos + width*2
	#var currentPos = box.global_position.x
	#$songOptions.position.x = -currentPos + boxWidth*2
func label_update(box):
	box_selected.emit(box.song_title.rstrip(".dat"))
	current_selection = box

#enter song mode with selected song
func second_press(box):
	print("button pressed:" + box.song_title)
	MusicVisualizerVariables.song_to_load = box.song_title
	SceneSwitcher.SwitchScene("SongMode")
