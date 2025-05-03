using Godot;
using System;

public partial class NoteHandler : Node
{
	public void ReceiveDetectedNotes(int[] detectedNotes, int timePlayed)
	{
		//GD.Print("Received detected notes: " + string.Join(",", detectedNotes));

		if (detectedNotes != null && detectedNotes.Length > 0)
		{

			// send the detected note to be compared
			Note newNote = new Note(detectedNotes, timePlayed);
			NoteComparison.AddInputNote(newNote);
		}
	}
}
