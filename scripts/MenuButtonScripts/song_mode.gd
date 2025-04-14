extends Control
class_name NSongMode
@onready var staff := $"staffCreation/staff"

func _ready():
	#adjust staff based on set size
	staff.add_theme_constant_override("margin_bottom", MusicVisualizerVariables.BOTTOM)
	staff.add_theme_constant_override("margin_top", MusicVisualizerVariables.TOP)

func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		#make pause screen popup
		SceneSwitcher.SwitchScene("Home")
		
