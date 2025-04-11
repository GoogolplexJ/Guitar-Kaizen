extends Control
class_name NSongMode
@onready var staff := $"staffCreation/staff"

func _ready():
	#adjust staff based on set size
	staff.size = Vector2(1920, MusicVisualizerVariables.WIDTH)
	staff.position = Vector2(0, MusicVisualizerVariables.BOTTOM)

func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		#make pause screen popup
		SceneSwitcher.SwitchScene("Home")
		
