using Godot;
using System;
using System.Collections.Generic;

public partial class NoteComparison : Node
{
	private static Stack<Note> inputNotesStack = new();  // Stack to hold the detected notes
	private static Stack<Note> idealNotesStack = new();  // Stack to hold the ideal notes for comparison
	private static List<Grade> gradeList = new();  // List to store grades for pitch and timing

	// Add an input note to the comparison stack
	public static void AddInputNote(Note note)
	{
		inputNotesStack.Push(note);  // Add the detected note to the stack
		TryCompareNotes();  // Try to compare the notes if there are enough notes to compare
	}

	// Add an ideal note to the comparison stack
	public static void AddIdealNote(Note note)
	{
		idealNotesStack.Push(note);  // Add the ideal note to the stack
		TryCompareNotes();  // Try to compare the notes if there are enough notes to compare
	}

	// This method compares the detected notes to the ideal notes
	private static void TryCompareNotes()
	{
		while (inputNotesStack.Count > 0 && idealNotesStack.Count > 0)
		{
			Note inputNote = inputNotesStack.Pop();  // Get the next detected note
			Note idealNote = idealNotesStack.Pop();  // Get the next ideal note

			int pitchScore = inputNote.CompareTo(idealNote);  // Get the pitch score from the comparison
			double timingDiff = System.Math.Abs(inputNote.GetLength() - idealNote.GetLength());  // Calculate the timing difference
			int timingScore = JudgeTiming(timingDiff);  // Judge the timing score based on the difference

			GD.Print($"Pitch Score: {pitchScore}/5, Timing Score: {timingScore}/5");  // Print the scores

			gradeList.Add(new Grade(pitchScore, timingScore));  // Store the grade for this note
		}
	}

	// This method judges the timing score based on how close the timing is to the ideal note
	private static int JudgeTiming(double diff)
	{
		if (diff < 0.1) return 5;  // Perfect timing
		else if (diff < 0.25) return 4;  // Good timing
		else if (diff < 0.5) return 3;  // Okay timing
		else if (diff < 1.0) return 2;  // Poor timing
		else return 1;  // Bad timing
	}

	// This method reports the final grades once all notes have been compared
	public static void ReportFinalGrades()
	{
		if (gradeList.Count == 0)
		{
			GD.Print("No grades to report.");
			return;
		}

		double pitchTotal = 0;
		double timingTotal = 0;

		// Calculate the total scores for pitch and timing
		foreach (var grade in gradeList)
		{
			pitchTotal += grade.GetPitchScore();
			timingTotal += grade.GetTimingScore();
		}

		// Scale the scores to be out of 100
		double pitchOutOf100 = (pitchTotal / (gradeList.Count * 5)) * 100;
		double timingOutOf100 = (timingTotal / (gradeList.Count * 5)) * 100;

		GD.Print($"Final Pitch Score: {pitchOutOf100:F2}/100");
		GD.Print($"Final Timing Score: {timingOutOf100:F2}/100");
	}
}
