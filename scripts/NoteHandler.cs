using Godot;
using System;
using System.Collections.Generic;
using System.Diagnostics;

public partial class NoteHandler : Node
{
	private Stack<int[]> detectedNotesStack = new();  // A stack to hold the detected notes
	private Stopwatch noteTimer = new();  // Stopwatch to track how long a note is held

	public override void _Ready()
	{
		noteTimer.Start();  // Start the stopwatch when the node is ready
	}

	// This method receives the detected notes and calculates how long each note was held
	public void ReceiveDetectedNotes(int[] detectedNotes)
	{
		GD.Print("Received detected notes: " + string.Join(",", detectedNotes));

		if (detectedNotes != null && detectedNotes.Length > 0)
		{
			double noteLength = noteTimer.Elapsed.TotalSeconds;  // Get the length of the note based on the stopwatch
			noteTimer.Restart();  // Restart the timer to track the next note
			CreateAndSendNote(detectedNotes, noteLength);  // Create the note object and send it for comparison
		}
	}

	// This method creates a Note object and passes it to NoteComparison for comparison
	private void CreateAndSendNote(int[] notes, double length)
	{
		Note newNote = new Note(length, notes);  // Create a new note object
		NoteComparison.AddInputNote(newNote);  // Add the note to the comparison list
	}
}
