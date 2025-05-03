using Godot;
using System;

// Note is the backbone of the project, most everything that deals with notes goes through the Note class
// This means it must be versitile, and able to handle notes from player input and notes from the in game song
// The class is a comparible to allow for the scoring and feedback that forms the rythm game
public partial class Note : Node, IComparable<Note>
{
	public double length; // for timing purposes, how long the note is playing
	public int[] notes; // arrays of notes played at the same time
	public int sharpFlat; 
	public int[] sign;
	public int timePlayed;

	// constructor for player-side notes
	public Note(int[] n, int tP)
	{
		notes = n;
		timePlayed = tP;
	}

	// constructor for computer side notes, defaulted to all signs as none
	public Note(double l, int[] n)
	{
		length = l;
		notes = n;
		sign = new int[notes.Length];
		Array.Fill(sign, 0);
	}

	// constructor for computer side notes, including signs
	public Note(double l, int[] n, int[] s)
	{
		length = l;
		notes = n;
		sign = s;
	}

	// blank constructor and initializer for use with GDScript
	public Note(){
	}

	//written by: Alicia
	public int[] GetNotes() { return notes; }
	public void SetNotes(int[] value) { notes = value; }
	public int[] GetSign() { return sign; }
	public void SetSign(int[] value) { sign = value; }
	public double GetLength() { return length; }
	public void SetLength(double value) { length = value; }
	public int GetSharpFlat() { return sharpFlat; }
	public void SetSharpFlat(int value) { sharpFlat = value; }


	// CompareTo method compares notes based on pitch
	// written by: Jared
	public int CompareTo(Note other)
	{
		int matchedNotes = 0;

		for (int i = 0; i < notes.Length; i++)
		{
			for (int j = 0; j < other.notes.Length; j++)
			{
				if (notes[i] == other.notes[j])
				{
					matchedNotes++;
					break; // don't double-count
				}
			}
		}

		if (matchedNotes >= notes.Length)
			return 5; // perfect match
		else if (matchedNotes >= notes.Length * 0.75)
			return 4; // good
		else if (matchedNotes >= notes.Length * 0.5)
			return 3; // ok
		else if (matchedNotes >= notes.Length * 0.25)
			return 2; // poor
		else
			return 1; // bad
	}

}
