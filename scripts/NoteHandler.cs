using Godot;
using System;
using System.Collections.Generic;
using System.Diagnostics;

public partial class NoteHandler : Node
{
	private Stopwatch noteTimer = new Stopwatch(); // keeps track of time since song started
	private bool firstNoteHeard = false; // to avoid overwriting first detection time

	public override void _Ready()
	{
		noteTimer.Start(); // start timer when scene is ready
	}

	public void ReceiveDetectedNotes(int[] detectedNotes)
	{
		GD.Print("Received detected notes: " + string.Join(",", detectedNotes));

		if (detectedNotes != null && detectedNotes.Length > 0)
		{
			// only set time once after signal
			if (!firstNoteHeard)
			{
				double detectedTime = noteTimer.Elapsed.TotalSeconds;
				NoteComparison.SetFirstNoteHeardTime(detectedTime);
				firstNoteHeard = true;
			}

			// send the detected note to be compared
			Note newNote = new Note(0, detectedNotes);
			NoteComparison.AddInputNote(newNote);
		}
	}

	public void ResetNoteDetection()
	{
		firstNoteHeard = false; // reset so next note gets timestamped
	}
}
