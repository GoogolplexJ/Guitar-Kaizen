#modified from https://kidscancode.org/godot_recipes/4.x/ui/level_select/index.html

@tool
extends Control

signal level_selected

@export var locked = true:
	set = set_locked
@export var song_cover = load("res://icon.svg"): #placeholder
	set = set_cover
@export var song_title = "hot Cross Buns": #placeholder
	set = set_title
#maybe add songPlayer object associated with song

@onready var lock = $PanelContainer/disabled
@onready var cover = $PanelContainer/cover

var title

func set_locked(value):
	locked = value
	if not is_inside_tree():
		await ready
	lock.visible = value
	cover.disabled = value

func set_cover(value : Texture):
	song_cover = value
	if not is_inside_tree():
		await ready
	cover.texture_normal = song_cover

func set_title(value):
	title = value

func _on_gui_input(event):
	if locked:
		return
	if event is InputEventMouseButton and event.pressed:
		level_selected.emit(title)
		print("Clicked level ", title)
