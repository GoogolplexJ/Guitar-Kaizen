using Godot;
using System;

public partial class Note : Node, IComparable<Note>
{
	private double length;  // The length of the note (how long it's held)
	private int[] notes;    // The array of notes represented by numbers
	private int sharpFlat;  // Whether the note is sharp (1), flat (-1), or neither (0)
	private int[] sign;     // To handle sharps/flats for each note in the array

	// Constructor to create a note from an array of notes and a sharp/flat value
	public Note(int[] n, int sF)
	{
		notes = n;
		sharpFlat = sF;
	}

	// Constructor to create a note with its length and an array of notes
	public Note(double l, int[] n)
	{
		length = l;
		notes = n;
		sign = new int[notes.Length];
		Array.Fill(sign, 0);  // Initializes all notes as natural (0 for no sharp/flat)
	}

	// Constructor to create a note with length, notes, and their sharp/flat values
	public Note(double l, int[] n, int[] s)
	{
		length = l;
		notes = n;
		sign = s;
	}

	// Default constructor
	public Note() {}

	// Getters and setters for notes, sign, length, and sharp/flat values
	public int[] GetNotes() { return notes; }
	public void SetNotes(int[] value) { notes = value; }

	public int[] GetSign() { return sign; }
	public void SetSign(int[] value) { sign = value; }

	public double GetLength() { return length; }
	public void SetLength(double value) { length = value; }

	public int GetSharpFlat() { return sharpFlat; }
	public void SetSharpFlat(int value) { sharpFlat = value; }

	// CompareTo method compares notes based on pitch
	public int CompareTo(Note other)
	{
		int goodness = 0;
		int howIsPitch = 0;
		
		// Compare each note's pitch
		for (int i = 0; i < notes.Length; i++)
		{
			for (int j = 0; j < other.notes.Length; j++)
			{
				if (notes[i] == other.notes[j])  // If the notes match in pitch
				{
					howIsPitch++;
				}
			}
		}

		// If all notes match in pitch, we give it the highest score (5)
		if (howIsPitch == notes.Length)
		{
			goodness = 5;
		}
		else
		{
			goodness = 1;  // If not all notes match, score it poorly (1)
		}

		return goodness;
	}
}
