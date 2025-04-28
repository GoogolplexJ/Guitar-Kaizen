extends Control

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("ui_cancel")):
		#switch to shutting settings screen instead of returning home
		self.queue_free()


func _on_fs_button_toggled(toggled_on: bool) -> void:
	#reference code
	#var mode := DisplayServer.window_get_mode()
	#var is_window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if is_window else DisplayServer.WINDOW_MODE_WINDOWED)
	if toggled_on:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	
func _on_home_button_pressed() -> void:
	SceneSwitcher.SwitchScene("Home")
	self.queue_free()

func _on_quit_button_pressed() -> void:
	SceneSwitcher.QuitGame()
