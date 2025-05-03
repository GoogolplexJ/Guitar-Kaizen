//written by: Jared, Alicia
//
using Godot;
using System;
using System.Collections.Generic;

public partial class NoteComparison : Node
{
	private static Stack<Note> inputNotesStack = new Stack<Note>();
	private static Stack<Note> idealNotesStack = new Stack<Note>();
	private static List<Grade> gradeList = new List<Grade>();



	// game added a note to expect
	public static void AddIdealNote(Note note)
	{
		idealNotesStack.Push(note);
		TryCompareNotes(); // check if we can compare
	}

	// played note is added to stack
	public static void PushDetectedNote(int[] detectedNotes, int timePlayed)
	{
		GD.Print("Received detected notes: " + string.Join(",", detectedNotes));
		// send the detected note to be compared
		Note newNote = new Note(detectedNotes, timePlayed);
		inputNotesStack.Push(newNote);
	}

	// check if we can compare notes and score them
	private static void TryCompareNotes()
	{
		while (idealNotesStack.Count > 0)
		{
			Note idealNote = idealNotesStack.Pop();
			Note inputNote;
			if(inputNotesStack.Count > 0){
				inputNote = inputNotesStack.Pop();
			}
			else{
				inputNote = new Note([0], 0);
			}

			int pitchScore = idealNote.CompareTo(inputNote);
			int timingScore = 1; // default if no signal timing

			// if we know both signal and first note time, calculate timing score
			double gap = Math.Abs((idealNote.timePlayed - inputNote.timePlayed) / 1000.0);
			// arbiutray values in seconds set
			if (gap < 0.1) timingScore = 5;
			else if (gap < 0.25) timingScore = 4;
			else if (gap < 0.5) timingScore = 3;
			else if (gap < 1.0) timingScore = 2;
			else timingScore = 1;
			if(gap < 0) timingScore = -1;


			GD.Print("Pitch Score: " + pitchScore + "/5, Timing Score: " + timingScore + "/5");
			gradeList.Add(new Grade(pitchScore, timingScore));
		}
	}

	// show final results
	public static void ReportFinalGrades()
	{
		if (gradeList.Count == 0)
		{
			GD.Print("No grades to report."); // Debug statemnet
			return;
		}

		double pitchTotal = 0;
		double timingTotal = 0;

		for (int i = 0; i < gradeList.Count; i++)
		{
			pitchTotal += gradeList[i].GetPitchScore();
			timingTotal += gradeList[i].GetTimingScore();
		}

		double pitchOutOf100 = (pitchTotal / (gradeList.Count * 5)) * 100;
		double timingOutOf100 = (timingTotal / (gradeList.Count * 5)) * 100;

		GD.Print("Final Pitch Score: " + pitchOutOf100.ToString("F2") + "/100"); // 2 decimal places 
		GD.Print("Final Timing Score: " + timingOutOf100.ToString("F2") + "/100");
	}
}
