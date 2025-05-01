#written by: Gabrielle Geppert
#tested by: Gabrielle Geppert
#debugged by: Gabrielle Geppert

extends Control

var file_name := "noNameSong"

func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		SceneSwitcher.SwitchScene("Home")


func _on_text_edit_text_changed() -> void:
	file_name = $CanvasLayer/TextEdit.text


func _on_play_button_pressed() -> void:
	MusicVisualizerVariables.song_to_load = file_name
	SceneSwitcher.SwitchScene("SongMode")
