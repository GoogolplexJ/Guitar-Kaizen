using Godot;
using System;
using System.IO;

public partial class FileWriter : Node
{
	public StreamWriter sW;
	string exeFolder = System.IO.Path.GetDirectoryName("Guitar Kaizen/Assets/Song Text Files");
	public FileWriter(){
	}
	public void CreateSW(string str, bool append){
		string s = exeFolder + str + ".txt";
		sW = new StreamWriter(s, append);
	}
	public void Append(string str){
		sW.Write(str);
	}
}
