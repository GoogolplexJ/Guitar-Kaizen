using Godot;
using System;

// unimplemented
// Code that holds song-side notes and performs the comparison between the player and the notes
public partial class SongPlayer : Node
{
	int timeSignatureTop;
	int timeSignatureBottom;
	int bpm;
	SongController controller;
	Note[] noteList;
	public SongPlayer(SongController c){
		controller = c;
		noteList = new Note[c.getNumNotes()];
	}
	
	//blank constructor for gdscript
	public SongPlayer(){
	}
	
		 // starts the song and sends ideal notes
	public void LoadAndStartSong()
	{
		NoteComparison.StartSongTimer();

		for (int i = 0; i < noteList.Length; i++)
		{
			NoteComparison.AddIdealNote(noteList[i]);
		}
	}

	// stop song and report scores
	public void EndSong()
	{
		NoteComparison.StopSongTimer();
		NoteComparison.ReportFinalGrades();
	}
}
