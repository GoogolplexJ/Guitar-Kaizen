extends Node

#configuration for the music visuals (staff generation and note generation)
static var BOTTOM = 290
static var WIDTH := 500
static var STAFF_DIV := 25

#the width of the gap between note positions
var line_width := WIDTH/STAFF_DIV
	#each note will be positioned at (BOTTOM + line_width(notePositionValue))
