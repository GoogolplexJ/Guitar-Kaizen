//written by: Alicia
//
using Godot;
using System;
using System.Collections.Generic;
using System.Diagnostics;

public partial class NoteComparison : Node
{
	private static Stack<Note> inputNotesStack = new Stack<Note>();
	private static Stack<Note> idealNotesStack = new Stack<Note>();
	private static List<Grade> gradeList = new List<Grade>();

	private static Stopwatch songTimer = new Stopwatch(); // using C#s Stopwatch rather than Godots built in Timer
	private static double signalReceivedTime = -1.0;
	private static double firstNoteHeardTime = -1.0;

	// someone played a note
	public static void AddInputNote(Note note)
	{
		inputNotesStack.Push(note);
		TryCompareNotes(); // check if we have a note to compare to
	}

	// game added a note to expect
	public static void AddIdealNote(Note note)
	{
		idealNotesStack.Push(note);
		TryCompareNotes(); // check if we can compare
	}

	// start timing when song starts
	public static void StartSongTimer()
	{
		songTimer.Restart();
	}

	public static void StopSongTimer()
	{
		songTimer.Stop();
	}

	// this is the time when the game says the note should be played
	public static void CollisionSignalReceived()
	{
		signalReceivedTime = songTimer.Elapsed.TotalSeconds;
		firstNoteHeardTime = -1.0; // reset
	}

	// store when the user actually played the note
	public static void SetFirstNoteHeardTime(double time)
	{
		if (firstNoteHeardTime < 0)
		{
			firstNoteHeardTime = time;
		}
	}

	// check if we can compare notes and score them
	private static void TryCompareNotes()
	{
		while (idealNotesStack.Count > 0)
		{
			Note idealNote = idealNotesStack.Pop();
			Note inputNote = inputNotesStack.Pop();
			if(inputNotesStack.Count > 0){
				inputNote = inputNotesStack.Pop();
			}
			else{
				inputNote = new Note([0], 0);
			}

			int pitchScore = inputNote.CompareTo(idealNote);
			int timingScore = 1; // default if no signal timing

			// if we know both signal and first note time, calculate timing score
			if (signalReceivedTime >= 0 && firstNoteHeardTime >= 0)
			{
				double gap = Math.Abs(firstNoteHeardTime - signalReceivedTime);
				// arbiutray values in seconds set
				if (gap < 0.1) timingScore = 5;
				else if (gap < 0.25) timingScore = 4;
				else if (gap < 0.5) timingScore = 3;
				else if (gap < 1.0) timingScore = 2;
				else timingScore = 1;
			}

			GD.Print("Pitch Score: " + pitchScore + "/5, Timing Score: " + timingScore + "/5");
			gradeList.Add(new Grade(pitchScore, timingScore));
		}
	}

	// show final results
	public static void ReportFinalGrades()
	{
		if (gradeList.Count == 0)
		{
			GD.Print("No grades to report."); // Debugg statemnet
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
