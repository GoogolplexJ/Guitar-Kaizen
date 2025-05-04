#written by: Gabrielle Geppert
#tested by: Gabrielle Geppert
#debugged by: Gabrielle Geppert

extends Node
#stores global variables for note visuals and staff visuals
#also stores name of song file to be loaded

#configuration for the music visuals (staff generation and note generation)
static var BOTTOM = 250
static var WIDTH := 700
static var STAFF_DIV := 26

var TOP : int = 1080 - BOTTOM - WIDTH
#the width of the gap between note positions
var line_width := WIDTH/(STAFF_DIV/2)
	#each note will be positioned at (BOTTOM + line_width(notePositionValue))

#the position on the staff which notes spawn in (referenced from the top left of the screen)
var staffMiddleY = TOP + WIDTH/2

#point on screen that denotes where notes are supposed to be played
var LIMIT_LINE = 100

var song_to_load = "noNameSong"
