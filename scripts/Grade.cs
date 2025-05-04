// Written by: Kei Khalid
// Tested by: Kei Khalid
// Debugged by: Kei Khalid

public class Grade
{
	private int pitchScore;  // score for how correct the note pitch was
	private int timingScore; // score for how close it was to the perfect timing

	public Grade(int pitchScore, int timingScore)
	{
		this.pitchScore = pitchScore;
		this.timingScore = timingScore;
	}

	public int GetPitchScore()
	{
		return pitchScore;
	}

	public void SetPitchScore(int value)
	{
		pitchScore = value;
	}

	public int GetTimingScore()
	{
		return timingScore;
	}

	public void SetTimingScore(int value)
	{
		timingScore = value;
	}
}
