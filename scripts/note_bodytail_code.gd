#written by: Gabrielle Geppert
#tested by: Gabrielle Geppert
#debugged by: Gabrielle Geppert

extends RigidBody2D
#include note class in code
const Note := preload("res://scripts/Note.cs")
#path with all note assets
static var SPRITE_PATH := "res://assets/noteGenerationAssets/" 

enum {REST, SIXTEENTH, EIGTH, QUARTER, HALF, WHOLE} 
static var spriteScale := Vector2(0.5, 0.5)

#create a note visual: unclustered notes only need Note, clustered notes need extreme note position
#input: note - Note object corresponding to the current note(s) in the song being read
#result: generation of a visual representation of the note or chord in the input
#NOTE: simultaneous notes which are not in the same chord are unsupported, all notes in the array will be added to the same chord
func create_note_vis(note : Note, barNotePos : int = 0):
	#print(note.length)
	
	#handle rests
	if (note.notes[0] == 0):
		handle_rests(note)
		return
	
	var extremeNote := note_body(note)
	note_tail(note, extremeNote, barNotePos)
	
#handle rest visual generation (no other work needed for rests)
func handle_rests(note : Note):
	var sprite = choose_rest_sprite(note.length)
		#create a 2Dsprite node for the body
	var restSprite = Sprite2D.new()
	add_child(restSprite)
	restSprite.texture = load(sprite)
	#TODO: choose sprite position
	#get rid of all other visual nodes in the tree
	node_culling(REST)
	
#create visuals for all note values in Note.notes list
func note_body(note : Note) -> int:
	#pull body sprite 
	var bodySprite := choose_body_sprite(note.length)
	#generate the body for each note value in the list
	#pull the position value of the most extreme note (highest or lowest -> farthest from the middle)
	var extremeNote := 12
	var i = 0
	for n in note.notes:
		var sF = note.sign[i]
		var currentNotePos = note_pos_value(n, sF) 
		create_n_body(currentNotePos, sF, bodySprite)
		#add a point to the line for each note value
		$noteTail.add_point(Vector2(0, tail_pos_calc(currentNotePos)))
		#compare most extreme found note to current note
		if (abs(12 - currentNotePos) > abs(12- extremeNote)):
			extremeNote = currentNotePos
		#extremeNote = max(abs(12 - currentNotePos), extremeNote)
		#print extremenote to terminal for testing
		#print(extremeNote)
		i += 1
	return extremeNote
	
func note_tail(note : Note, extremeNote : int, barNotePosition : int):
	#check if the note is a whole note which doesnt have a tail
		#if it is, remove the tail nodes and return from function
	if (note.length == 1):
		node_culling(WHOLE)
		return
	#color the tail black
	var noteTailNode := $noteTail
	noteTailNode.set_default_color(Color(0, 0, 0, 1))
	#check if the note is in a quarter/eigth note cluster
		#if yes decide tail end point based off of farthest note
	#TODO: figure out barNotePosition stuff
	var tailEndPoint : int
	var tailEndPos : int
	if (barNotePosition != 0):
		#tailEndPoint = calculated from barNotePosition
		tailEndPos = tail_pos_calc(tailEndPoint)
		noteTailNode.add_point(Vector2(0, tailEndPos))
		noteTailNode.set_closed(true)
		node_culling(EIGTH)
		return
	else:
		#store the length of the tails for notes in the middle of the staff (in # of positions)
		var tailMidLength := 4
		#decide note tail end position based on most extreme note (converted position value)
		#notes <= 6 have same end point (center)
		#notes >= 30 have same end point (center)
		if (extremeNote <= 6 || extremeNote >= 20):
			tailEndPoint = 0
		#notes <= 12 have same tail length, tail goes up (start point + length)
		elif (extremeNote <= 12):
			tailEndPoint = extremeNote + tailMidLength
		#notes > 12 have same tail length, tail goes down (start point - length)
		elif (extremeNote > 12):
			tailEndPoint = extremeNote - tailMidLength
		
		tailEndPos = tail_pos_calc(tailEndPoint)
		noteTailNode.add_point(Vector2(0, tailEndPos))
		noteTailNode.set_closed(true)
	
	var noteFlourishNode = $noteTail/tailFlourish
	#decide tailFlourish texture & position
	var flourishPath = choose_flourish_sprite(note.length)
	if note.length >= (1.0/4): return
	noteFlourishNode.texture = load(flourishPath)
	#flourish goes at the top of the line
	var maxPoint = tail_pos_calc(12)
	for point in noteTailNode.points:
		maxPoint = min(point.y,maxPoint)
	noteFlourishNode.offset.y = maxPoint + 80 #offset added to account for texture height
	noteFlourishNode.offset.x = -noteFlourishNode.texture.get_width()/2

#create visuals for current note being inspected in Note.notes list
func create_n_body(currentNotePos : int, sharpFlat : int, bodySprite : String):
	#because some Notes are actually chords (multiple notes played at once), they may need multiple note bodies
		#for each value in the notes array, create a new 2Dsprite node and choose its position (texures are all the same)
	var body = Sprite2D.new()
	add_child(body)
	body.texture = load(bodySprite)
	body.scale = spriteScale
	body.offset.x = body.texture.get_width()/2
	#note position: handle in a separate function
	body.offset.y = note_pos_calc(currentNotePos)
	#decide sharpFlat texture and add 2Dsprite node 
	#0 = no sharp/flat
	if sharpFlat != 0:
		var sFNode = Sprite2D.new()
		add_child(sFNode)
		var sFsprite = choose_sharpFlat_sprite(sharpFlat)
		sFNode.texture = load(sFsprite)
		sFNode.scale = spriteScale
		#sharp flat position: offset from body position
		sFNode.offset.y = note_pos_calc(currentNotePos)
		sFNode.offset.x = body.offset.x + 120 #NOTE: 10 is an arbitrary offset value, refine after testing
		#y position is relative to other notes -> middle B is at y = 0: other notes are offset according to stave width
		#for chords, check if note is a chord (multiple values in note array), then for each note which is on a line, check if there are notes in the chord within 2 spaces
			#if there is a note within 2 spaces, flip the note on the line to the other side

#return note position relative to the center of the staff (-12 (highest) to 12 (lowest)-> 11 is actual lowest note since rest is at 0)
func note_pos_calc(posValue : int) -> int:
	#if note is a rest, it should be in the center
	if posValue == 0:
		return 0
	#calculate note position relative to center note (center B = note position 12)
	var relPos = -(posValue - 12)
	return (MusicVisualizerVariables.line_width*relPos)

func tail_pos_calc(posValue : int) -> int:
	return note_pos_calc(posValue)/2

func choose_body_sprite(noteLength : float) -> String:
	#print(noteLength)
	match noteLength:
			1.0:
				return SPRITE_PATH + "wholeBody.png"
			(1.0/2):
				return SPRITE_PATH + "halfBody.png"
			_:
				return SPRITE_PATH + "quarterBody.png" 

func choose_rest_sprite(noteLength : float) -> String:
	#print(noteLength)
	match noteLength:
		1.0:
			return SPRITE_PATH + "wholeRest.png"
		(1.0/2):
			return SPRITE_PATH + "halfRest.png"
		(1.0/4):
			return SPRITE_PATH + "quarterRest.png"
		(1.0/8):
			return SPRITE_PATH + "eigthRest.png"
		(1.0/16):
			return SPRITE_PATH + "sixteenthRest.png"
		_:
			return ""

func choose_flourish_sprite(noteLength : float) -> String:
	#print(noteLength)
	match noteLength:
		1.0/8:
		#sixteenth note, eigth note = unique tail flourish textures ONLY IF they are NOT in a cluster
			return SPRITE_PATH + "eigthFlourish.png"
		1.0/16:
			return SPRITE_PATH + "sixteenthFlourish.png"
		_:
		#quarter, half note = none
			node_culling(HALF)
			return ""

func choose_sharpFlat_sprite(sF : int) -> String:
	match sF:
		#1 = sharp
		1:
			return SPRITE_PATH + "sharp.png"
		#2 = flat (default)
		_:
			return SPRITE_PATH + "flat.png"

#input: type - what type of note is being created; flourish - whether or not the note should have a tail flourish (eigth and sixteenth only)
#result: get rid of all unneeded nodes for visual generation
#WARNING: make sure function is exited before reaching any of the code dealing with deleted nodes, only call once per note generation
func node_culling(type : int, flourish := false):
	match type:
		REST, WHOLE: 
			$noteTail.queue_free()
			return
		HALF, QUARTER:
			$noteTail/tailFlourish.queue_free()
			return
		EIGTH, SIXTEENTH:
			#if in a note cluster, get rid of flourish
			if flourish == false: $noteTail/tailFlourish.queue_free()
			return

#input: note value (0-40) including sharps; sharpFlat: integer corresponding to whether the note is flat,sharp, or neither (0,1,2)
#output: note position assignment (1-24), combining sharps/flats with corresponding note
func note_pos_value(value : int, sharpFlat : int) -> int:
	#if note is a rest, return 0 (position indicating rest)
	if value == 0:
		return 0
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
