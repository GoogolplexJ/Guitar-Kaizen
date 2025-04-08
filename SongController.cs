using Godot;
using System;
using System.Dynamic;

public partial class SongController : Node
{
    int numNotes;

    public SongController(){

    }

    public int getNumNotes(){
        return numNotes;
    }
}
