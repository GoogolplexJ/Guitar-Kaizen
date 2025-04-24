using Godot;
using System;
using System.ComponentModel;

// enum for signs attached to notes
/*
public enum {
	none,
	sharp,
	flat
}*/

// Note is the backbone of the project, most everything that deals with notes goes through the Note class
// This means it must be versitile, and able to handle notes from player input and notes from the in game song
// The class is a comparible to allow for the scoring and feedback that forms the rythm game
public partial class Note : Node, IComparable<Note>
{
	double length; // for timing purposes, how long the note is playing
	int[] notes; // arrays of notes played at the same time
	int sharpFlat; 

	int[] sign;
	
	// constructor for player-side notes
	public Note(int[] n, int sF){
		notes = n;
		sharpFlat = sF;
	}

	// constructor for computer side notes, defaulted to all signs as none
	public Note(double l, int[] n){
		length = l;
		notes = n;
		sign = new int[notes.Length];
		Array.Fill<int>(sign, 0);
	}

	// constructor for computer side notes, including signs
	public Note(double l, int[] n, int[] s){
		length = l;
		notes = n;
		sign = s;
	}
	
	// blank constructor and initializer for use with GDScript
	public Note(){
	}
	



	// comparison function to allow for notes to be compared for accuracy
	public int CompareTo(Note other) // 5 is perfect, 4 is good, 3 is ok, 2 is poor, 1 is bad
	{
		int goodness = 0;
		int howIsPitch = 0;
		for(int i = 0; i < notes.Length; i++){
			for(int j = 0; j < other.notes.Length; j++){
				if(notes[i] == other.notes[j]){
					howIsPitch++;
				}

		}
		if(howIsPitch  == notes.Length){
			goodness = 5;
		}

		}
		return (goodness);
	}

}
