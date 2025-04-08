extends Control
class_name CHome

func _ready():
	$"topLayer/screen margins/button title formatting/buttons/GameMode".grab_focus()

func _on_ModeButton_pressed():
	SceneSwitcher.SwitchScene("GameModeSelect")
	
