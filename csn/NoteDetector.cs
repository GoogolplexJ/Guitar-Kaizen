//using Godot;
//using System;
//using System.Collections.Generic;
//using System.Linq;
//
//public partial class NoteDetector : Control // Ensure it inherits from Control
//{
	//// --- Configuration Parameters ---
	//[Export] public string AudioBusName = "Master";
	//[Export(PropertyHint.Range, "0,10,")] public int SpectrumAnalyzerEffectIndex = 0;
	//[Export(PropertyHint.Range, "-90,-10")] public float MagnitudeThresholdDb = -45.0f; // START HERE FOR TUNING
	//[Export(PropertyHint.Range, "1,100")] public float NoteDetectionToleranceCents = 35.0f;
	//[Export(PropertyHint.Range, "1,10")] public int PeakDetectionNeighbourWidth = 3;
	//[Export] public float MinFrequencyHz = 70.0f;
	//[Export] public float MaxFrequencyHz = 1400.0f;
//
	//// --- Signals ---
	//[Signal]
	//public delegate void NotesDetectedEventHandler(Godot.Collections.Array<string> noteNames);
//
	//// --- Private Variables ---
	//private AudioEffectSpectrumAnalyzerInstance _analyzerInstance = null;
	//private float _sampleRate = 0;
	//private int _fftSize = 0;
	//private float _freqResolution = 0;
	//private readonly Dictionary<string, float> _noteFrequencies = new Dictionary<string, float>();
	//private List<KeyValuePair<string, float>> _sortedNoteFrequencies = new List<KeyValuePair<string, float>>();
	//private Vector2[] _lastSpectrumForDraw = null;
	//private Godot.Collections.Array<string> _lastDetectedNotesForDraw = new Godot.Collections.Array<string>();
//
	//// Debugging flags/counters
	//private bool _readyCalled = false;
	//private bool _analyzerConnected = false;
	//private ulong _processFrameCount = 0; // Use ulong for frame count
//
//
	//// --- Constants ---
	//private const float A4_FREQ = 440.0f;
	//private readonly string[] NOTE_NAMES = { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" };
//
	//// --- Godot Methods ---
	//public override void _Ready()
	//{
		//GD.Print($"NoteDetector: _Ready() called for node '{Name}'. Path: {GetPath()}");
		//// Ensure this node processes otherwise _Process and _Draw won't run
		//SetProcess(true);
		//// Ensure drawing is enabled
		//SetProcessMode(ProcessModeEnum.Always); // Or Pausable/Inherit as needed
//
		//SetupNoteFrequencies();
		//ConnectToSpectrumAnalyzer(); // This now sets _analyzerConnected flag
//
		//if (!_analyzerConnected)
		//{
			//GD.PushError($"{Name}: Initialization failed. Check audio bus/effect settings. Disabling processing.");
			//SetProcess(false); // Disable processing and drawing if setup failed
		//}
		//else
		//{
			 //GD.Print($"{Name}: Initialization successful. Monitoring bus '{AudioBusName}' effect index {SpectrumAnalyzerEffectIndex}.");
		//}
		//_readyCalled = true;
	//}
//
	//public override void _Process(double delta)
	//{
		//_processFrameCount++;
//
		//if (!_readyCalled || !_analyzerConnected || _analyzerInstance == null)
		//{
			 //// Print error only once per second to avoid spam
			 //if(_processFrameCount % 60 == 1)
				//GD.PushWarning("NoteDetector._Process: Skipping frame - not ready or analyzer not connected.");
			 //return;
		//}
//
		//// --- Debug: Print every ~2 seconds to confirm _Process is running ---
		//if (_processFrameCount % 120 == 1)
		//{
			//GD.Print($"NoteDetector._Process: Running (Frame: {_processFrameCount}). Analyzer instance valid: {_analyzerInstance != null}");
		//}
//
		//// 1. Get Spectrum Data
		//_lastSpectrumForDraw = GetSpectrumData();
		//if (_lastSpectrumForDraw == null || _lastSpectrumForDraw.Length == 0)
		//{
			 //if(_processFrameCount % 60 == 1) // Print warning periodically
				//GD.PushWarning("NoteDetector._Process: GetSpectrumData returned null or empty.");
			 //_lastDetectedNotesForDraw = new Godot.Collections.Array<string>(); // Clear notes if no spectrum
			 //EmitSignal(SignalName.NotesDetected, _lastDetectedNotesForDraw); // Emit empty array
			 //QueueRedraw(); // Still redraw (to show empty graph)
			 //return; // Cannot proceed without spectrum data
		//}
//
		//// --- Debug: Print spectrum info periodically ---
		 //if (_processFrameCount % 120 == 5) // Offset from the process running message
		 //{
			//float maxMag = -200.0f;
			//foreach(var v in _lastSpectrumForDraw) { if (v.Y > maxMag) maxMag = v.Y; }
			//GD.Print($"NoteDetector._Process: Spectrum received. Bins: {_lastSpectrumForDraw.Length}. Max Magnitude Found: {maxMag:F1} dB");
		 //}
//
		//// 2. Find Peaks
		//List<KeyValuePair<float, float>> peaks = FindFrequencyPeaks(_lastSpectrumForDraw);
//
		//// --- Debug: Print peak info ---
		 //if (_processFrameCount % 120 == 10)
		 //{
			 //GD.Print($"NoteDetector._Process: Found {peaks.Count} peaks above threshold ({MagnitudeThresholdDb} dB).");
			 //// Optional: Print details of first few peaks
			 //// foreach(var peak in peaks.Take(5)) { GD.Print($"  - Freq: {peak.Key:F1} Hz, Mag: {peak.Value:F1} dB"); }
		 //}
//
//
		//// 3. Detect Notes
		//HashSet<string> detectedNotes = DetectNotesFromPeaks(peaks);
		//var noteArray = new Godot.Collections.Array<string>(detectedNotes);
//
		//// --- Compare with last emission to reduce signal spam if notes haven't changed ---
		//// This is an optimization, can be removed if causing issues
		//bool notesChanged = !_lastDetectedNotesForDraw.SequenceEqual(noteArray);
		//if(notesChanged)
		//{
			//_lastDetectedNotesForDraw = noteArray; // Store for drawing and next comparison
			//// 4. Emit Signal ONLY if notes changed
			//EmitSignal(SignalName.NotesDetected, noteArray);
		//}
		//else {
			 //_lastDetectedNotesForDraw = noteArray; // Still update for drawing even if not emitting
		//}
//
//
		//// 5. Request Redraw for the frequency chart
		//QueueRedraw();
	//}
//
	//public override void _Draw()
	//{
		//// Add more checks here
		//if (!_readyCalled) { GD.Print("NoteDetector._Draw: Skipped - _Ready not finished."); return; }
		//if (_analyzerInstance == null) { GD.Print("NoteDetector._Draw: Skipped - Analyzer instance is null."); return; }
		//if (!Visible) { /* Optionally print: GD.Print("NoteDetector._Draw: Skipped - Node not visible."); */ return; }
//
		//float graphHeight = Size.Y;
		//float graphWidth = Size.X;
//
		//if (graphHeight <= 0 || graphWidth <= 0)
		//{
			//// Print warning only occasionally
			//if (_processFrameCount % 120 == 15)
				//GD.Print($"NoteDetector._Draw: Skipped - Invalid size ({graphWidth}x{graphHeight}). Ensure node has size in Layout.");
			//return;
		//}
//
		//// --- Debug: Confirm Draw is called with valid size ---
		//if (_processFrameCount % 120 == 15)
		//{
			 //GD.Print($"NoteDetector._Draw: Drawing graph. Size: {graphWidth}x{graphHeight}");
		//}
//
//
		//// --- Draw Setup ---
		//DrawRect(new Rect2(0, 0, graphWidth, graphHeight), new Color(0.1f, 0.1f, 0.15f, 0.8f));
//
		//// --- Define Plotting Ranges ---
		//// (Ensure robust calculation against zero/negative/equal min/max frequencies)
		//float safeMinFreq = Mathf.Max(1.0f, MinFrequencyHz);
		//float safeMaxFreq = Mathf.Max(safeMinFreq + 1.0f, MaxFrequencyHz); // Ensure max > min
		//float minLogFreq = Mathf.Log(safeMinFreq);
		//float maxLogFreq = Mathf.Log(safeMaxFreq);
		//float logFreqRange = maxLogFreq - minLogFreq;
		//if (logFreqRange <= 0) logFreqRange = 1.0f;
//
		//float maxDb = 0f;
		//float minDb = -70f; // Adjust this range if needed
		//float dbRange = maxDb - minDb;
		//if (dbRange <= 0) dbRange = 90.0f;
//
		//// --- Draw Spectrum Line ---
		//if (_lastSpectrumForDraw != null && _lastSpectrumForDraw.Length > 0) // Check if data exists
		//{
			//List<Vector2> spectrumPoints = new List<Vector2>();
			//foreach (Vector2 point in _lastSpectrumForDraw)
			//{
				//float freq = point.X;
				//float magDb = point.Y;
//
				//if (freq < safeMinFreq || freq > safeMaxFreq || magDb < minDb) continue;
//
				//float logFreq = Mathf.Log(Mathf.Max(1.0f, freq));
				//float x = graphWidth * (logFreq - minLogFreq) / logFreqRange;
				//float y = graphHeight * (1.0f - (Mathf.Clamp(magDb, minDb, maxDb) - minDb) / dbRange);
				//spectrumPoints.Add(new Vector2(x, y));
			//}
//
			//if (spectrumPoints.Count > 1)
			//{
				//DrawPolyline(spectrumPoints.ToArray(), Colors.Yellow, 1.0f);
			//}
		//} else {
			 //// Optionally draw a message if no spectrum data
			 //DrawString(ThemeDB.FallbackFont, new Vector2(10, 20), "No Spectrum Data", HorizontalAlignment.Left, -1, 16, Colors.Red);
		//}
//
//
		//// --- Draw Detected Note Lines and Text ---
		//// (Rest of the drawing code remains the same as before)
		//Font font = ThemeDB.FallbackFont;
		//int fontSize = ThemeDB.FallbackFontSize;
		//Color noteColor = Colors.LightBlue;
		//Color textColor = Colors.White;
//
		//var sortedDrawableNotes = _lastDetectedNotesForDraw
									//.Where(note => _noteFrequencies.ContainsKey(note))
									//.OrderBy(note => _noteFrequencies[note])
									//.ToList();
		//float lastTextEndX = -10;
//
		//foreach (string note in sortedDrawableNotes)
		//{
			 //if (_noteFrequencies.TryGetValue(note, out float noteFreq))
			 //{
				 //if (noteFreq >= safeMinFreq && noteFreq <= safeMaxFreq)
				 //{
					 //float noteLogFreq = Mathf.Log(Mathf.Max(1.0f, noteFreq));
					 //float x = graphWidth * (noteLogFreq - minLogFreq) / logFreqRange;
					 //DrawLine(new Vector2(x, 0), new Vector2(x, graphHeight), noteColor, 1);
					 //Vector2 textPos = new Vector2(x + 3, graphHeight - fontSize - 2);
					 //if (textPos.X < lastTextEndX) { textPos.Y -= (fontSize + 2); }
					 //DrawString(font, textPos, note, HorizontalAlignment.Left, -1, fontSize, textColor);
					 //lastTextEndX = textPos.X + font.GetStringSize(note, HorizontalAlignment.Left, -1, fontSize).X;
				 //}
			 //}
		//}
	//}
//
	//// --- Core Logic Methods (Modified ConnectToSpectrumAnalyzer) ---
//
	//private void ConnectToSpectrumAnalyzer()
	//{
		//_analyzerConnected = false; // Assume failure until success
		//int busIndex = AudioServer.GetBusIndex(AudioBusName);
		//if (busIndex < 0)
		//{
			//GD.PushError($"{Name}: Audio bus '{AudioBusName}' not found.");
			//return;
		//}
		//GD.Print($"NoteDetector: Found bus '{AudioBusName}' at index {busIndex}.");
//
		//var effect = AudioServer.GetBusEffect(busIndex, SpectrumAnalyzerEffectIndex) as AudioEffectSpectrumAnalyzer;
		//if (effect == null)
		//{
			//GD.PushError($"{Name}: No AudioEffectSpectrumAnalyzer found on bus '{AudioBusName}' at index {SpectrumAnalyzerEffectIndex}.");
			//return;
		//}
		 //GD.Print($"NoteDetector: Found effect at index {SpectrumAnalyzerEffectIndex}. Type: {effect.GetType().Name}");
//
//
		//_analyzerInstance = AudioServer.GetBusEffectInstance(busIndex, SpectrumAnalyzerEffectIndex) as AudioEffectSpectrumAnalyzerInstance;
//
		//if (_analyzerInstance == null)
		//{
			 //GD.PushError($"{Name}: Failed to get AudioEffectSpectrumAnalyzerInstance. Ensure game is running, not just editor script.");
			 //return;
		//}
		//GD.Print($"NoteDetector: Got Analyzer Instance: {_analyzerInstance}");
//
//
		//_sampleRate = (float)ProjectSettings.GetSetting("audio/driver/mix_rate");
		//_fftSize = (int)effect.FftSize;
		//if (_fftSize == 0) {
			 //GD.PushError($"{Name}: FFT Size is zero! Check SpectrumAnalyzer settings in Audio bus.");
			 //return; // Cannot proceed with FFT size 0
		//}
		//_freqResolution = _sampleRate / _fftSize;
//
		//GD.Print($"{Name}: Connection successful. SampleRate={_sampleRate}, FftSize={_fftSize}, FreqResolution={_freqResolution:F2} Hz/bin");
		//_analyzerConnected = true; // Set flag on success
	//}
//
	//// --- GetSpectrumData, FindFrequencyPeaks, DetectNotesFromPeaks, SetupNoteFrequencies, FindClosestNote remain the same ---
	//// (Include the full code for these methods from the previous response)
	 //private Vector2[] GetSpectrumData()
	//{
		//// Add check for analyzer instance validity
		//if (_analyzerInstance == null || _fftSize == 0 || !_analyzerConnected) return null;
//
		//int binCount = _fftSize / 2;
		//Vector2[] spectrumMagnitudes = new Vector2[binCount];
//
		//for (int i = 0; i < binCount; i++)
		//{
			//float currentFreq = i * _freqResolution;
			//float nextFreq = (i + 1) * _freqResolution;
			//float centerFreq = currentFreq + _freqResolution / 2.0f;
//
			//Vector2 mag = _analyzerInstance.GetMagnitudeForFrequencyRange(currentFreq, nextFreq);
			//spectrumMagnitudes[i] = new Vector2(centerFreq, mag.Y);
		//}
		//return spectrumMagnitudes;
	//}
//
	 //private List<KeyValuePair<float, float>> FindFrequencyPeaks(Vector2[] spectrum)
	//{
		//List<KeyValuePair<float, float>> peaks = new List<KeyValuePair<float, float>>();
		//// Check spectrum validity added
		//if (spectrum == null || spectrum.Length < PeakDetectionNeighbourWidth * 2 + 1)
		//{
			//return peaks;
		//}
//
		//for (int i = PeakDetectionNeighbourWidth; i < spectrum.Length - PeakDetectionNeighbourWidth; i++)
		//{
			//float freq = spectrum[i].X;
			//float mag = spectrum[i].Y;
//
			//if (mag < MagnitudeThresholdDb || freq < MinFrequencyHz || freq > MaxFrequencyHz)
			//{
				//continue;
			//}
//
			//bool isPeak = true;
			//for (int j = 1; j <= PeakDetectionNeighbourWidth; j++)
			//{
				 //if (spectrum[i - j].Y > mag || spectrum[i + j].Y > mag)
				//{
					//isPeak = false;
					//break;
				//}
			//}
//
			//if (isPeak)
			//{
				//peaks.Add(new KeyValuePair<float, float>(freq, mag));
				//i += PeakDetectionNeighbourWidth;
			//}
		//}
		//return peaks;
	//}
//
	//private HashSet<string> DetectNotesFromPeaks(List<KeyValuePair<float, float>> peaks)
	//{
		//HashSet<string> detectedNotes = new HashSet<string>();
		//// Check peaks validity
		//if (peaks == null) return detectedNotes;
//
		//foreach (var peak in peaks)
		//{
			//float peakFreq = peak.Key;
			//string closestNote = FindClosestNote(peakFreq, out float centsDifference);
//
			//if (!string.IsNullOrEmpty(closestNote) && Mathf.Abs(centsDifference) <= NoteDetectionToleranceCents)
			//{
				//detectedNotes.Add(closestNote);
			//}
		//}
		//return detectedNotes;
	//}
//
	//private void SetupNoteFrequencies()
	//{
		//_noteFrequencies.Clear();
		//_sortedNoteFrequencies.Clear();
		//for (int octave = 0; octave < 9; octave++)
		//{
			//for (int noteIndex = 0; noteIndex < 12; noteIndex++)
			//{
				//int midiNoteNumber = 12 + (octave * 12) + noteIndex;
				//double freq = A4_FREQ * Math.Pow(2.0, (midiNoteNumber - 69.0) / 12.0);
				//string noteName = NOTE_NAMES[noteIndex] + octave.ToString();
				//_noteFrequencies.Add(noteName, (float)freq);
			//}
		//}
		//_sortedNoteFrequencies.AddRange(_noteFrequencies);
		//_sortedNoteFrequencies.Sort((a, b) => a.Value.CompareTo(b.Value));
		//GD.Print($"Generated {_noteFrequencies.Count} standard note frequencies.");
	//}
//
	//private string FindClosestNote(float targetFreq, out float centsDifference)
	//{
		//centsDifference = float.MaxValue;
		//if (_sortedNoteFrequencies.Count == 0 || targetFreq <= 0) return null;
//
		//string bestNote = null;
		//float minAbsCents = float.MaxValue;
//
		//foreach(var noteInfo in _sortedNoteFrequencies)
		//{
			//float noteFreq = noteInfo.Value;
			//if (noteFreq <= 0) continue;
			//float currentCentsDiff = 1200.0f * (float)Math.Log(targetFreq / noteFreq, 2.0);
			//float absCents = Mathf.Abs(currentCentsDiff);
			//if (absCents < minAbsCents)
			//{
				 //minAbsCents = absCents;
				 //bestNote = noteInfo.Key;
				 //centsDifference = currentCentsDiff;
			//}
		//}
		//return bestNote;
	//}
//}
