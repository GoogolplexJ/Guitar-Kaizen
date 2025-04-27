extends Control
class_name NSongMode
@onready var staff := $"staffCreation/staff"
@onready var staffBack := $"staffCreation/staff background"
@onready var noteTimer := $notes/noteTimer
@onready var colLine := $notes/lineCollision
const Note := preload("res://scripts/Note.cs")
const SongPlayer := preload("res://scripts/SongPlayer.cs")
@export var note_visual_scene : PackedScene
@export var song_mode_controller_scene : PackedScene
@export var test_song : PackedScene

var song : SongPlayer
var songModeControl
#start delay before notes move, starts the noteTimer on timeout
func _on_start_timer_timeout() -> void:
	noteTimer.start()
	#set note timing based on first note in sequence
	noteTimer.wait_time = songModeControl.note_timing_calc(songModeControl.noteLength.pop_back())
	$notes/startLabel.visible = false

#next note starts moving once the note timer runs out
func _on_note_timer_timeout() -> void:
	#handle note spawning before song starts: code below is for testing
		#var nextNote = create_test_note()
		#var nextNoteVis = spawn_note(nextNote)
	var nextNote = songModeControl.noteVisNodes.pop_back() #grab next note from the note queue
	if !nextNote:
		noteTimer.paused = true
		return
	nextNote.linear_velocity.x = songModeControl.song_speed() #assign linear velocity to note based on song speed (semi arbitrary, since note timing is what actually matters)
	#set timer for next note
	noteTimer.wait_time = songModeControl.note_timing_calc(songModeControl.noteLength.pop_back())
	
#TODO: note collision detection with the end line
func _on_line_collision_body_entered(body: Node2D) -> void:
	$notes/lineCollision/ColorRect.color(Color(0, 1, 1, 1))
	
func _ready():
	#adjust staff based on set size
	staff.add_theme_constant_override("margin_bottom", MusicVisualizerVariables.BOTTOM)
	staff.add_theme_constant_override("margin_top", MusicVisualizerVariables.TOP)
	
	staffBack.add_theme_constant_override("margin_bottom", MusicVisualizerVariables.BOTTOM - 20)
	staffBack.add_theme_constant_override("margin_top", MusicVisualizerVariables.TOP - 20)
	
	colLine.position.y = MusicVisualizerVariables.staffMiddleY
	colLine.position.x = MusicVisualizerVariables.LIMIT_LINE
	
	songModeControl = song_mode_controller_scene.instantiate()
	$notes.add_child(songModeControl)
	#generate all note visuals before song starts
	#NOTE: after new songs have been implemented, change to loading real song rather than test
	var test = test_song.instantiate()
	song = test.create_test_song()
	songModeControl.song = song
	songModeControl.load_song()
	#start the start timer so that there is a delay before the notes move
	$notes/startTimer.start()

func _process(delta) -> void:
	$notes/startLabel.set_text(str(int($notes/startTimer.get_time_left()+1)))

func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		#make pause screen popup
		SceneSwitcher.SwitchScene("Home")
