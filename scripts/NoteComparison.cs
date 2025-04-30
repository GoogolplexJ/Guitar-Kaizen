using Godot;
using System;
using System.Collections.Generic;

public partial class NoteComparison : Node
{
	private Stack<Note> inputNotesStack = new Stack<Note>();
	private Stack<Note> idealNotesStack = new Stack<Note>();

	// Add a note played by the player
	public void AddInputNote(Note note)
	{
		inputNotesStack.Push(note);
		TryCompareNotes();
	}

	// Add a note from the expected melody (computer)
	public void AddIdealNote(Note note)
	{
		idealNotesStack.Push(note);
		TryCompareNotes();
	}

	// Attempt comparison if both stacks have notes
	private void TryCompareNotes()
	{
		while (inputNotesStack.Count > 0 && idealNotesStack.Count > 0)
		{
			Note inputNote = inputNotesStack.Pop();
			Note idealNote = idealNotesStack.Pop();

			// Use the Note's CompareTo method for pitch comparison
			int pitchScore = inputNote.CompareTo(idealNote);

			// Use timing difference between ideal and player notes
			double inputLength = inputNote.GetLength();
			double idealLength = idealNote.GetLength();
			double timingDiff = Math.Abs(inputLength - idealLength);
			int timingScore = JudgeTiming(timingDiff);

			GD.Print($"Pitch Score: {pitchScore}/5, Timing Score: {timingScore}/5");
		}
	}

	// Simple scoring logic based on timing difference in seconds
	private int JudgeTiming(double diff)
	{
		if (diff < 0.1) return 5;    // perfect
		else if (diff < 0.25) return 4; // good
		else if (diff < 0.5) return 3;  // okay
		else if (diff < 1.0) return 2;  // poor
		else return 1;              // bad
	}
	
	public static void AcceptNote(Note note)
	{
		// Assuming this is used for testing individual notes
		GD.Print("NoteComparison received note: " + note.ToString());
	}
}
