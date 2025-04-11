extends Node

const Note := preload("res://scripts/Note.cs")
static var SPRITE_PATH := "res://assets/noteGenerationAssets/" 

#create a note visual: unclustered notes only need Note, clustered notes need extreme note position
func create_note_vis(note : Note, extremeNotePos : int = 0):
	#handle rests
	if (note.notes[0] == 0):
		handle_rests(note)
		return
	
	var extremeNote := note_body(note)
	note_tail(note, extremeNote)
	
#handle rest visual generation (no other work needed for rests)
func handle_rests(note : Note):
	match note.length:
		1:
			bodySprite += "wholeRest.png"
		(1/2):
			bodySprite += "halfRest.png"
		(1/4):
			bodySprite += "quarterRest.png"
		(1/8):
			bodySprite += "eigthRest.png"
		(1/16):
			bodySprite += "sixteenthRest.png"
		#create a 2Dsprite node for the body
	var restSprite = Sprite2D.new()
	add_child(restSprite)
	restSprite.texture = bodySprite
	#TODO: choose sprite position
	#get rid of all other visual nodes in the tree
	node_culling(WHOLE)
	
#create visuals for all note values in Note.notes list
func note_body(note : Note) -> int:
	#pull body sprite 
	var bodySprite := choose_body_sprite(note.length)
	#generate the body for each note value in the list
	#pull the position value of the most extreme note (highest or lowest -> farthest from the middle)
	
	var extremeNote := 0
	for n in note.notes:
		var currentNotePos = note_position_value(n) #FIXME: make sure function matches actual value
		create_n_body(currentNotePos, sF, bodySprite) #FIXME: make sure note sharpflat value is passed in
		extremeNote = max(abs(12 - currentNotePos), extremeNote)
		
	return extremeNote
	
func note_tail(note : Note, extremeNote : int):

#create visuals for current note being inspected in Note.notes list
func create_n_body(currentNotePos : int, sharpFlat : int, bodySprite : String, arr : Array[Node]):
	
		
			
func choose_body_sprite(noteLength : int) -> String:
	match noteLength:
			1:
				return SPRITE_PATH + "wholeBody.png"
			(1/2):
				return SPRITE_PATH + "halfBody.png"
			_:
				return SPRITE_PATH + "quarterBody.png" 
