extends Control
class_name CHome

func _ready():
	$"topLayer/screen margins/button title formatting/buttons/GameMode".grab_focus()

func _on_ModeButton_pressed():
	SceneSwitcher.SwitchScene("GameModeSelect")
	
func _on_Creation_pressed() -> void:
	SceneSwitcher.SwitchScene("SongCreation")

func _on_quit_pressed() -> void:
	SceneSwitcher.QuitGame()

#allow access to testing screens
func _input(event):
	if (event.is_action_pressed("enter_noteVis_debug")):
		SceneSwitcher.SwitchScene("noteTest")
