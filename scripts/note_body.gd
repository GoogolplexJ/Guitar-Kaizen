extends RigidBody2D

#include Note class code
const Note := preload("res://scripts/Note.cs")
	#set texture based on note type
	#$Sprite2D.texture = load("path")
enum {REST, SIXTEENTH, EIGTH, QUARTER, HALF, WHOLE}

#input: note - Note object corresponding to the current note(s) in the song being read
#result: generation of a visual representation of the note or chord in the input
func create_note_visual(note : Note):
	#NOTE: simultaneous notes which are not in the same chord are unsupported, all notes in the array will be added to the same chord
		var spritePath := "res://assets/noteGenerationAssets/" 
	#region creating the note body
		var bodySprite := spritePath
		#region rest handling
		#first check if note is a rest (note value = 0)
			#if it is, decide texture here instead and ignore all other visual instructions
		if (note.notes[0] == 0):
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
			#end function without executing the rest
			return
			#endregion
		#decide noteBody texture based on note length (all notes below half have the same body (TODO: ADD DOTTED note SUPPORT)
		match note.length:
			1:
				bodySprite += "wholeBody.png"
			(1/2):
				bodySprite += "halfBody.png"
			_:
				bodySprite += "quarterBody.png"
		#because some Notes are actually chords (multiple notes played at once), they may need multiple note bodies
		#for each value in the notes array, create a new 2Dsprite node and choose its position (texures are all the same)
		var bodyArray = []
		var i = 0 #array counter
		for noteValue in note.notes:
			bodyArray[i] = Sprite2D.new()
			add_child(bodyArray[i])
			i += 1
			bodyArray[i].texture = bodySprite
			#region sharp flat icon TODO
				#decide sharpFlat texture and add 2Dsprite node
			#endregion
			#TODO: note position: handle in a separate function
			#y position is relative to other notes -> middle C is at y = 0: other notes are offset according to stave width
			#for chords, check if note is a chord (multiple values in note array), then for each note which is on a line, check if there are notes in the chord within 2 spaces
				#if there is a note within 2 spaces, flip the note on the line to the other side
				#to check whether note is on a line, divide by total octaves to figure out which note in the octave it is, then account for sharps
	#endregion
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
	#endregion
	#for notes in clusters, draw a note connector line (or two, for eigth notes) between the end point of each note's tail
	
#input: type - what type of note is being created; flourish - whether or not the note should have a tail flourish (eigth and sixteenth only)
#result: get rid of all unneeded nodes for visual generation
#WARNING: make sure function is exited before reaching any of the code dealing with deleted nodes, only call once per note generation
func node_culling(type : int, flourish := false):
	match type:
		REST: 
			$sharpFlat.queue_free()
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
		
#func note_position(value : int):
		
