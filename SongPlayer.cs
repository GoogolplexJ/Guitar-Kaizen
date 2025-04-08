using Godot;
using System;

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
}
