extends Control
class_name CHome

@export var settings_scene : PackedScene

func _ready():
	$"topLayer/screen margins/button title formatting/buttons/GameMode".grab_focus()

func _on_ModeButton_pressed():
	SceneSwitcher.SwitchScene("GameModeSelect")
	
func _on_Creation_pressed() -> void:
	SceneSwitcher.SwitchScene("SongCreation")

func _on_quit_pressed() -> void:
	SceneSwitcher.QuitGame()
	
func _on_settings_pressed() -> void:
	var settingsScreen = settings_scene.instantiate()
	$topLayer.add_child(settingsScreen)

#allow access to testing screens
func _input(event):
	if (event.is_action_pressed("enter_noteVis_debug")):
		SceneSwitcher.SwitchScene("noteTest")
	if (event.is_action_pressed("enter_noteDetect_debug")):
		SceneSwitcher.SwitchScene("noteDetectorTest")
