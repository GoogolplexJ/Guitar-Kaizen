using Godot;
using System;
using System.Dynamic;

// unimplemented
// Controls the song player to allow for more in depth understanding of the whole song, pre-loaded
public partial class SongController : Node
{
	int numNotes;

	public SongController(){

	}

	public int getNumNotes(){
		return numNotes;
	}
}
