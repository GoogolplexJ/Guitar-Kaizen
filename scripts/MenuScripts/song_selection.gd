#written by: Gabrielle Geppert
#tested by: Gabrielle Geppert
#debugged by: Gabrielle Geppert

extends Control
@onready var songOptions := $CanvasLayer/MarginContainer/clipControl/songOptions
@onready var menuControl := $CanvasLayer/MarginContainer/clipControl
@onready var selectionDisplay := $CanvasLayer/selectionDisp
#menu movement variables
var boxWidth = 380
var numBoxes := 0
var boxList : Array[Node]
var currentBox := 1

var file_name := "noNameSong"

func _ready() -> void:
	#move songOptions box so first song is in the middle of the screen on load
	songOptions.position.x = boxWidth*2
	boxList = songOptions.get_children()
	numBoxes = boxList.size()
	#connect selection signal from clipControl (menu) to selectionDisp
	#menuControl.box_selected.connect(selectionDisplay.update_title)


func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		SceneSwitcher.SwitchScene("Home")

#when arrow buttons (leftButton and rightButton) are pressed, move the songOptions box so that the next song is in the middle
#TODO: box in the middle should also be selected
func _on_left_button_pressed() -> void:
	if currentBox < numBoxes -1:
		#songOptions.position.x += boxWidth
		currentBox += 1
		update_box()
	
func _on_right_button_pressed() -> void:
	if currentBox > 0:
		#songOptions.position.x -= boxWidth
		currentBox -= 1
		update_box()

func update_box():
	menuControl.first_press(boxList[currentBox - 1])

#signal methods for testing buttons
func _on_text_edit_text_changed() -> void:
	file_name = $CanvasLayer/TextEdit.text

func _on_play_button_pressed() -> void:
	MusicVisualizerVariables.song_to_load = file_name + ".dat"
	SceneSwitcher.SwitchScene("SongMode")
