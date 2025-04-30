using System.Collections.Generic;  // Ensure the required namespace for Stack is included
using Godot;
using System;

public partial class NoteHandler : Node  // Correctly place the 'public' modifier before 'class'
{
	private Stack<int[]> detectedNotesStack = new Stack<int[]>();  // Stack to store detected notes

	// Called from the chord_recog GDScript when notes are detected
	public void ReceiveDetectedNotes(int[] detectedNotes)
	{
		GD.Print("Received detected notes: " + string.Join(",", detectedNotes));  // Debug output

		if (detectedNotes != null && detectedNotes.Length > 0)
		{
			detectedNotesStack.Push(detectedNotes);  // Push detected notes onto the stack
			CreateAndSendNote();  // Create the Note object and send it for comparison
		}
	}

	// Creates the Note object and sends it to NoteComparison
	private void CreateAndSendNote()
	{
		if (detectedNotesStack.Count == 0)
		{
			return;  // Return early if no notes are in the stack
		}

		int[] notes = detectedNotesStack.Pop();  // Pop the latest detected notes
		GD.Print("Creating Note with notes: " + string.Join(",", notes));  // Debug output

		Note newNote = new Note(notes, 0);  // Create a new Note object with the detected notes (sharp/flat is set to 0 here)

		// Send the created Note object to the NoteComparison class
		NoteComparison.AcceptNote(newNote);
	}
}
