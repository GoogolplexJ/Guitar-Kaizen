#modified from https://kidscancode.org/godot_recipes/4.x/ui/level_select/index.html

@tool
extends Control

signal level_selected

@export var locked = true:
	set = set_locked
@export var song_cover = 1:
	set = set_level

@onready var lock = $PanelContainer/disabled/MarginContainer/lock
@onready var cover = $PanelContainer/cover

func set_locked(value):
	locked = value
	if not is_inside_tree():
		await ready
	lock.visible = value

func set_level(value):
	song_cover = value
	if not is_inside_tree():
		await ready
	cover.texture = song_cover


func _on_gui_input(event):
	if locked:
		return
	if event is InputEventMouseButton and event.pressed:
		level_selected.emit(song_cover)
		print("Clicked level ", song_cover)
