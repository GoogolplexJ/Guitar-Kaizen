#written by: Gabrielle Geppert
#tested by: Gabrielle Geppert
#debugged by: Gabrielle Geppert

extends Control
class_name CGameModeSelection

func _ready():
	$"CanvasLayer/song mode".grab_focus()

func _on_SongMode_pressed():
	SceneSwitcher.SwitchScene("SongSelection")

func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		SceneSwitcher.SwitchScene("Home")
		
