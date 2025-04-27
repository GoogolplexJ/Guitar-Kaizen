extends Control
class_name SongCreation

var toggleArray = []
var itemArray = []
var topText = ""
var botText = ""
var bpm = ""
var barLength = ""
var barType = 0 
var initialized = false
var file = FileAccess.open(save_path, FileAccess.WRITE)
var folder_path := "user://"
var save_name := "noNameSong.dat"
var save_path := folder_path + save_name

# when scene starts make sure variables are at default,
# then begin the text file editing so that song can be created
func _ready():
	_blank_variables()
	

func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		SceneSwitcher.SwitchScene("Home")
		
# resets variables to default values
func _blank_variables() -> void:
	toggleArray.clear()
	itemArray.clear()
	toggleArray.resize(24)
	toggleArray.fill(false)
	itemArray.resize(24)
	itemArray.fill(0)
	topText = ""
	botText = ""
	bpm = ""
	barLength = ""
	barType = 0 

# List Based Buttons, changes index in list to new value 
# based on which note changed
func _on__toggled(toggled_on: bool, extra_arg_0: int) -> void:
	toggleArray[extra_arg_0] = toggled_on
func _on_option_button_item_selected(index: int, extra_arg_0: int) -> void:
	itemArray[extra_arg_0] = index

# unselects all buttons back to default value
func _unselect_buttons() -> void:
	$Notes/Note1/OptionButton.selected = -1
	$Notes/Note1.button_pressed = false
	$Notes/Note2/OptionButton.selected = -1
	$Notes/Note2.button_pressed = false
	$Notes/Note3/OptionButton.selected = -1
	$Notes/Note3.button_pressed = false
	$Notes/Note4/OptionButton.selected = -1
	$Notes/Note4.button_pressed = false
	$Notes/Note5/OptionButton.selected = -1
	$Notes/Note5.button_pressed = false
	$Notes/Note6/OptionButton.selected = -1
	$Notes/Note6.button_pressed = false
	$Notes/Note7/OptionButton.selected = -1
	$Notes/Note7.button_pressed = false
	$Notes/Note8/OptionButton.selected = -1
	$Notes/Note8.button_pressed = false
	$Notes/Note9/OptionButton.selected = -1
	$Notes/Note9.button_pressed = false
	$Notes/Note10/OptionButton.selected = -1
	$Notes/Note10.button_pressed = false
	$Notes/Note11/OptionButton.selected = -1
	$Notes/Note11.button_pressed = false
	$Notes/Note12/OptionButton.selected = -1
	$Notes/Note12.button_pressed = false
	$Notes/Note13/OptionButton.selected = -1
	$Notes/Note13.button_pressed = false
	$Notes/Note14/OptionButton.selected = -1
	$Notes/Note14.button_pressed = false
	$Notes/Note15/OptionButton.selected = -1
	$Notes/Note15.button_pressed = false
	$Notes/Note16/OptionButton.selected = -1
	$Notes/Note16.button_pressed = false
	$Notes/Note17/OptionButton.selected = -1
	$Notes/Note17.button_pressed = false
	$Notes/Note18/OptionButton.selected = -1
	$Notes/Note18.button_pressed = false
	$Notes/Note19/OptionButton.selected = -1
	$Notes/Note19.button_pressed = false
	$Notes/Note20/OptionButton.selected = -1
	$Notes/Note20.button_pressed = false
	$Notes/Note21/OptionButton.selected = -1
	$Notes/Note21.button_pressed = false
	$Notes/Note22/OptionButton.selected = -1
	$Notes/Note22.button_pressed = false
	$Notes/Note23/OptionButton.selected = -1
	$Notes/Note23.button_pressed = false
	$Notes/Note24/OptionButton.selected = -1
	$Notes/Note24.button_pressed = false
	
	$TimeSignatures/TopSignature.clear()
	$TimeSignatures/BotSignature.clear()
	$BPM/BPM.clear()
	$Bars/BarLength.clear()
	$Bars/BarType.selected = -1
	
	pass # Replace with function body.

# signle variable buttons, set variable to new value
func _on_bar_length_text_changed() -> void:
	barLength = $Bars/BarLength.text
func _on_bar_type_item_selected(index: int) -> void:
	barType = index
func _on_bpm_text_changed() -> void:
	bpm = $BPM/BPM.text
func _on_bot_signature_text_changed() -> void:
	barLength = $TimeSignatures/BotSignature.text
func _on_top_signature_text_changed() -> void:
	barLength = $TimeSignatures/TopSignature.text


func _on_make_note_pressed() -> void:
	_unselect_buttons()
	_blank_variables()


func _on_make_bars_pressed() -> void:
	_unselect_buttons()
	_blank_variables()


func _on_make_bpm_pressed() -> void:
	_unselect_buttons()
	_blank_variables()


func _on_make_time_pressed() -> void:
	_unselect_buttons()
	_blank_variables()


func _on_overwrite_pressed() -> void:
	file = FileAccess.open(save_path, FileAccess.WRITE)
	file.resize(0)
	file.store_8(1)
	_unselect_buttons()
	_blank_variables()
	initialized = true

func _on_append_pressed() -> void:
	file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_8(1)
	_unselect_buttons()
	_blank_variables()
	initialized = true

func _on_name_text_changed() -> void:
	save_name = $Create/Name.text + ".dat"
	save_path = folder_path + save_name
