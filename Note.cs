using Godot;
using System;
using System.ComponentModel;

public partial class Note : Node, IComparable<Note>
{
	double length;
	int[] notes;
	int flatSharp;
	public Note(int[] n, int fS){
		notes = n;
		flatSharp = fS;
	}

	public Note(double l, int[] n){
		length = l;
		notes = n;
	}

    public int CompareTo(Note other)
    {
        for(int i = 0; i < notes.Length; i++){

		}
		return (0);
    }

}
