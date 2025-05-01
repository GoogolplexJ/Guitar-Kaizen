using Godot;
using System;

public partial class Note : Node, IComparable<Note>
{
	private double length;
	private int[] notes;      // this holds the pitch values
	private int sharpFlat;    // for future use maybe
	private int[] sign;       // for future use maybe

	// constructor when we know the notes and sharp/flat info
	public Note(int[] n, int sF)
	{
		notes = n;
		sharpFlat = sF;
	}

	// constructor when we know the length and notes
	public Note(double l, int[] n)
	{
		length = l;
		notes = n;
		sign = new int[notes.Length];
		Array.Fill(sign, 0);
	}

	// constructor when we also know the sign values
	public Note(double l, int[] n, int[] s)
	{
		length = l;
		notes = n;
		sign = s;
	}

	public Note() {}

	public int[] GetNotes() { return notes; }
	public void SetNotes(int[] value) { notes = value; }
	public int[] GetSign() { return sign; }
	public void SetSign(int[] value) { sign = value; }
	public double GetLength() { return length; }
	public void SetLength(double value) { length = value; }
	public int GetSharpFlat() { return sharpFlat; }
	public void SetSharpFlat(int value) { sharpFlat = value; }

	// CompareTo method compares notes based on pitch
	//written by: Alicia
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

		if (matchedNotes == notes.Length && notes.Length == other.notes.Length)
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
