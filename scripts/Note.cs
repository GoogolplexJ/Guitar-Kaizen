using Godot;
using System;
using System.ComponentModel;

public enum Sign{
	none,
	sharp,
	flat
}

public partial class Note : Node, IComparable<Note>
{
	double length;
	int[] notes;
	int sharpFlat;

	readonly Sign[] sign;
	
	public Note(int[] n, int sF){
		notes = n;
		sharpFlat = sF;
	}

	public Note(double l, int[] n){
		length = l;
		notes = n;
        sign = new Sign[notes.Length];
		Array.Fill<Sign>(sign, Sign.none);
	}

	public Note(double l, int[] n, Sign[] s){
		length = l;
		notes = n;
		sign = s;
	}


	public int CompareTo(Note other) // 5 is perfect, 4 is good, 3 is ok, 2 is poor, 1 is bad
	{
		int goodness = 0;
		int howIsPitch = 0;
		for(int i = 0; i < notes.Length; i++){
			for(int j = 0; j < other.notes.Length; j++){
				if(notes[i] == other.notes[j]){
					howIsPitch++;
				}

		}
		if(howIsPitch  == notes.Length){
			goodness = 5;
		}

		}
		return (goodness);
	}

}
