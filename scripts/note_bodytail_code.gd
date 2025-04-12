extends RigidBody2D
#include note class in code
const Note := preload("res://scripts/Note.cs")
#path with all note assets
static var SPRITE_PATH := "res://assets/noteGenerationAssets/" 

enum {REST, SIXTEENTH, EIGTH, QUARTER, HALF, WHOLE} 

#create a note visual: unclustered notes only need Note, clustered notes need extreme note position
#input: note - Note object corresponding to the current note(s) in the song being read
#result: generation of a visual representation of the note or chord in the input
#NOTE: simultaneous notes which are not in the same chord are unsupported, all notes in the array will be added to the same chord
func create_note_vis(note : Note, barNotePos : int = 0):
	#handle rests
	if (note.notes[0] == 0):
		handle_rests(note)
		return
	
	var extremeNote := note_body(note)
	note_tail(note, extremeNote, barNotePos)
	
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
	var i = 0
	for n in note.notes:
		var sF = note.sign[i]
		var currentNotePos = note_pos_value(n, sF) 
		create_n_body(currentNotePos, sF, bodySprite)
		#compare most extreme found note to current note
		extremeNote = max(abs(12 - currentNotePos), extremeNote)
		i += 1
	return extremeNote
	
func note_tail(note : Note, extremeNote : int, barNotePosition : int):
	#region decide noteTail length
		#first point of the tail vector is the position of the note body (based on which note it is)
		#check if the note is in a quarter/eigth note cluster
			#if yes, check if the note is the farthest from the center within its cluster
				#if it is, decide tail length as normal
				#if not, decide tail end point based off of farthest note
		#notes <= 8 have same end point (predetermined); notes < 23 have same tail length, tail goes up (start point + length)
		#notes >= 23 have same tail length, tail goes down (start point - length); notes >= 34 have same end point (predetermined)
	#endregion
	#region decide tailFlourish texture & position
	#decide tailFlourish texture & position
		#whole note, half note = none
		#quarter note, eigth note = unique tail flourish textures ONLY IF they are NOT in a cluster

#create visuals for current note being inspected in Note.notes list
#TODO: position assignment
func create_n_body(currentNotePos : int, sharpFlat : int, bodySprite : String):
	#because some Notes are actually chords (multiple notes played at once), they may need multiple note bodies
		#for each value in the notes array, create a new 2Dsprite node and choose its position (texures are all the same)
	var body = Sprite2D.new()
	add_child(body)
	body.texture = bodySprite
	#TODO: note position: handle in a separate function
	#decide sharpFlat texture and add 2Dsprite node
	if sharpFlat != Sign.none:
		var sFNode = Sprite2D.new()
		add_child(sFNode)
		var sFsprite = choose_sharpFlat_sprite(sharpFlat)
		sFNode.texture = sFsprite
		#TODO: sharp flat position: offset from body position
			
			#y position is relative to other notes -> middle B is at y = 0: other notes are offset according to stave width
			#for chords, check if note is a chord (multiple values in note array), then for each note which is on a line, check if there are notes in the chord within 2 spaces
				#if there is a note within 2 spaces, flip the note on the line to the other side

func choose_body_sprite(noteLength : int) -> String:
	match noteLength:
			1:
				return SPRITE_PATH + "wholeBody.png"
			(1/2):
				return SPRITE_PATH + "halfBody.png"
			_:
				return SPRITE_PATH + "quarterBody.png" 

func choose_sharpFlat_sprite(sF : int) -> String:
	match sF:
		Sign.sharp:
			return SPRITE_PATH + "sharp.png"
		Sign.flat:
			return SPRITE_PATH + "flat.png"

#input: type - what type of note is being created; flourish - whether or not the note should have a tail flourish (eigth and sixteenth only)
#result: get rid of all unneeded nodes for visual generation
#WARNING: make sure function is exited before reaching any of the code dealing with deleted nodes, only call once per note generation
func node_culling(type : int, flourish := false):
	match type:
		REST: 
			$noteTail.queue_free()
			$noteConnector.queue_free()
			return
		WHOLE:
			$noteConnector.queue_free()
			$noteTail.queue_free()
		HALF:
			$noteConnector.queue_free()
			$noteTail/tailFlourish.queue_free()
		QUARTER, SIXTEENTH:
			#if not in a note cluster, get rid of connector, else get rid of flourish
			if flourish: $noteConnector.queue_free()
			else: $noteTail/tailFlourish.queue_free()

#input: note value (0-40) including sharps; sharpFlat: integer corresponding to whether the note is flat,sharp, or neither (0,1,2)
#output: note position assignment (1-24), combining sharps/flats with corresponding note
func note_pos_value(value : int, sharpFlat : int) -> int:
	var newValue := value
	#adjust flats and sharps to their corresponding base note value
	match sharpFlat:
		0:
			newValue += 1
		1: 
			newValue -= 1
	#calculate new position value without sharps and flats
	newValue = int(newValue/2) + 1
	if value <= 9: return newValue
	elif (value <= 20): return newValue + 1
	elif (value <= 32): return newValue + 2
	else: return newValue + 3
	
#input: note position assignment (1-24)
#output: the y value of the position the note should be in
func body_position(posValue : int) -> int:
	return (MusicVisualizerVariables.BOTTOM + MusicVisualizerVariables.line_width*posValue)
