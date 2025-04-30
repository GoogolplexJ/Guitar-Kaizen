public class Grade
{
	private int pitchScore;  // This stores the score for how accurate the pitch was (out of 5)
	private int timingScore; // This stores the score for how accurate the timing was (out of 5)

	// Constructor to initialize the scores when we create a Grade object
	public Grade(int pitchScore, int timingScore)
	{
		this.pitchScore = pitchScore;
		this.timingScore = timingScore;
	}

	// Getters and setters for pitchScore
	public int GetPitchScore()
	{
		return pitchScore;
	}

	public void SetPitchScore(int value)
	{
		pitchScore = value;
	}

	// Getters and setters for timingScore
	public int GetTimingScore()
	{
		return timingScore;
	}

	public void SetTimingScore(int value)
	{
		timingScore = value;
	}
}
