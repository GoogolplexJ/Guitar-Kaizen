#written by: Gabrielle Geppert
#tested by: Gabrielle Geppert
#debugged by: Gabrielle Geppert

#modified from https://kidscancode.org/godot_recipes/4.x/ui/level_select/index.html

@tool
extends Control

@export var locked = true:
	set = set_locked
@export var song_cover = load("res://icon.svg"): #placeholder
	set = set_cover
@export var song_title = "hot Cross Buns": #placeholder
	set = set_title
var pos = 0
#maybe add songPlayer object associated with song

@onready var lock = $PanelContainer/disabled
@onready var cover = $PanelContainer/cover

#set function for locking song (useful later for level system)
func set_locked(value):
	locked = value
	if not is_inside_tree():
		await ready
	lock.visible = value
	cover.disabled = value

#set function for cover
func set_cover(value : Texture):
	song_cover = value
	if not is_inside_tree():
		await ready
	cover.texture_normal = song_cover

#set function for title (used to tell songMode which song to load)
func set_title(value):
	song_title = value
	#get rid of label when covers are implemented
	$Label.text = value.rstrip(".dat")

#misc get and set functions
func get_button() -> Node:
	return $PanelContainer/cover
func set_pos(value):
	pos = value
func get_pos() -> int:
	return pos
