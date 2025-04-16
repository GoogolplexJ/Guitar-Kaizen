extends Control
class_name NSongMode
@onready var staff := $"staffCreation/staff"
@onready var staffBack := $"staffCreation/staff background"

func _ready():
	#adjust staff based on set size
	staff.add_theme_constant_override("margin_bottom", MusicVisualizerVariables.BOTTOM)
	staff.add_theme_constant_override("margin_top", MusicVisualizerVariables.TOP)
	
	staffBack.add_theme_constant_override("margin_bottom", MusicVisualizerVariables.BOTTOM - 20)
	staffBack.add_theme_constant_override("margin_top", MusicVisualizerVariables.TOP - 20)

func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		#make pause screen popup
		SceneSwitcher.SwitchScene("Home")
		
