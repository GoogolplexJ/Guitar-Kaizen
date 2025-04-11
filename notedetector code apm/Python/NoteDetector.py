import pyaudio
import numpy as np
from scipy.fft import rfft, rfftfreq
from scipy.signal import find_peaks, peak_widths
import time
import math
import threading
from flask import Flask, jsonify
from flask_cors import CORS
from collections import deque
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker

# --- Configuration ---
CHUNK = 2048 * 2
FORMAT = pyaudio.paInt16
CHANNELS = 1
RATE = 44100

# --- Display Options ---
SHOW_SPECTROGRAM = True # Set to False to disable plotting for performance

# --- Tuning Parameters ---
# Frequency Range
MIN_FREQUENCY = 70
MAX_FREQUENCY = 1200

# --- NEW: Max notes for Multi-Mode ---
MAX_SIMULTANEOUS_NOTES = 3 # Limit the number of notes reported in multi-mode

# --- Initial Thresholds (Slightly increased from last diagnostic, tune these!) ---
MIN_RMS_VOLUME = 0.003   # Gate for overall quietness
MIN_PEAK_PROMINENCE = 0.01  # How much peak stands out locally
MIN_ABSOLUTE_PEAK_MAG = 0.005 # Minimum loudness of the peak itself

# Peak Shape / Harmonic Filtering (Enabled by default now)
MAX_PEAK_WIDTH_BINS_DEFAULT = 15  # Default width limit (Lower values are stricter)
MIN_PEAK_DISTANCE_HZ = 10

# Harmonic Check Settings (Enabled by default for Multi)
REQUIRE_HARMONICS_MULTI_DEFAULT = True # Default for multi-mode harmonic check
MIN_HARMONIC_COUNT_MULTI_DEFAULT = 1   # Default harmonics needed for Multi-Note
HARMONIC_SEARCH_TOLERANCE_HZ = 15
HARMONIC_MIN_MAG_RATIO = 0.05 # Strength ratio for harmonic peaks (Lower is less strict)
VALIDATE_SINGLE_NOTE_HARMONIC_DEFAULT = False # Default for single-mode harmonic check

# Temporal Filtering
TEMPORAL_WINDOW_SIZE = 3
MIN_CONSISTENT_DETECTIONS = 2

# Reference frequency for note calculation
A4_FREQ = 440.0
NOTES = ['A', 'A#', 'B', 'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#']

# --- Global variables ---
detection_mode = 'multi'
latest_confirmed_notes = []
data_lock = threading.Lock()
recent_detections_buffer = deque(maxlen=TEMPORAL_WINDOW_SIZE)
current_frame_raw_notes = set()
last_heartbeat_time = time.time()
HEARTBEAT_INTERVAL = 5.0

# --- Plotting Variables ---
plot_running = True
plot_fig = None
plot_ax = None
plot_line_spectrum = None
plot_scatter_peaks = None
# plot_bg = None # Removed - not used with simplified drawing

# --- Flask App Setup ---
app = Flask(__name__)
CORS(app)

# --- Helper Functions (Keep as they were) ---
def frequency_to_note_name(freq):
    if freq <= 0: return None
    half_steps = 12 * math.log2(freq / A4_FREQ)
    midi_note = round(half_steps) + 69
    note_index = (midi_note - 21) % 12
    octave = (midi_note - 12) // 12
    if 0 <= midi_note <= 127: return f"{NOTES[note_index]}{octave}"
    else: return None

def calculate_rms(audio_data):
    normalized_data = audio_data / 32768.0
    rms = np.sqrt(np.mean(normalized_data**2))
    return rms

# --- Peak Finding Logic (Keep as they were) ---
def find_peaks_with_properties(magnitudes, freqs, config):
    if not len(magnitudes) or not len(freqs) or len(freqs) < 2:
        return np.array([]), {}, np.array([])
    freq_resolution = freqs[1] - freqs[0]
    min_distance_indices = int(config['min_distance_hz'] / freq_resolution) if freq_resolution > 0 else 1
    peaks, properties = find_peaks(
        magnitudes, prominence=config['min_prominence'], distance=max(1, min_distance_indices)
    )
    valid_peak_indices = np.array([
        p for i, p in enumerate(peaks)
        if properties["prominences"][i] >= config['min_prominence'] and magnitudes[p] >= config['min_abs_mag']
    ])
    valid_properties = {}
    mask = np.array([], dtype=bool)
    if len(valid_peak_indices) > 0:
        mask = np.isin(peaks, valid_peak_indices)
        for key, value in properties.items():
             if isinstance(value, np.ndarray) and len(value) == len(peaks):
                 valid_properties[key] = value[mask]
             else: valid_properties[key] = value
    return valid_peak_indices, valid_properties, valid_peak_indices

def check_harmonics(fund_freq, fund_mag, all_peak_indices_relative, magnitudes_filtered, freqs_filtered, config):
    harmonic_count = 0
    harmonic_tolerance_hz = config['harmonic_tolerance_hz']
    min_ratio = config['harmonic_min_mag_ratio']
    for harmonic_multiple in range(2, 4):
        target_freq = fund_freq * harmonic_multiple
        min_freq = target_freq - harmonic_tolerance_hz
        max_freq = target_freq + harmonic_tolerance_hz
        for p_idx_relative in all_peak_indices_relative:
            if p_idx_relative < len(freqs_filtered):
                 p_freq = freqs_filtered[p_idx_relative]
                 if min_freq <= p_freq <= max_freq:
                     if p_idx_relative < len(magnitudes_filtered):
                         p_mag = magnitudes_filtered[p_idx_relative]
                         if p_mag >= fund_mag * min_ratio:
                             harmonic_count += 1
                             break
    return harmonic_count

# --- Main Processing Function (Called in Thread) ---
def process_audio_chunk(audio_data, config, mode):
    """Processes a single audio chunk for note detection based on mode."""
    global current_frame_raw_notes, plot_fig, plot_ax, plot_line_spectrum, plot_scatter_peaks

    # Initialize lists for this frame's results
    detected_fundamental_freqs = []
    detected_fundamental_mags = []
    plot_peak_freqs = []
    plot_peak_mags = []
    xf_filtered, magnitudes_filtered = np.array([]), np.array([])

    rms_volume = calculate_rms(audio_data)
    if rms_volume < config['min_rms_volume']:
        current_frame_raw_notes = set()
    else:
        window = np.hanning(len(audio_data))
        audio_data_windowed = audio_data * window
        yf = rfft(audio_data_windowed)
        xf = rfftfreq(len(audio_data_windowed), 1 / RATE)
        magnitudes = np.abs(yf) / CHUNK
        valid_indices = (xf >= config['min_freq']) & (xf <= config['max_freq'])

        if not np.any(valid_indices):
             current_frame_raw_notes = set()
        else:
            xf_filtered = xf[valid_indices]
            magnitudes_filtered = magnitudes[valid_indices]

            all_peaks_indices_relative, properties, _ = find_peaks_with_properties(
                magnitudes_filtered, xf_filtered, config
            )

            if len(all_peaks_indices_relative) > 0:
                all_peak_freqs = xf_filtered[all_peaks_indices_relative]
                all_peak_mags = magnitudes_filtered[all_peaks_indices_relative]

                if mode == 'single':
                    # --- Single Note Logic (Keep as before) ---
                    strongest_peak_local_idx = np.argmax(all_peak_mags)
                    single_freq = all_peak_freqs[strongest_peak_local_idx]
                    single_mag = all_peak_mags[strongest_peak_local_idx]
                    passes_harmonic_check = True
                    if config['validate_single_harmonic']:
                         harmonic_count = check_harmonics(single_freq, single_mag, all_peaks_indices_relative, magnitudes_filtered, xf_filtered, config)
                         if harmonic_count == 0: passes_harmonic_check = False
                    if passes_harmonic_check:
                        detected_fundamental_freqs = [single_freq]
                        detected_fundamental_mags = [single_mag]
                        # For plotting, show only the single detected note
                        plot_peak_freqs = detected_fundamental_freqs
                        plot_peak_mags = detected_fundamental_mags

                elif mode == 'multi':
                    # --- Multi Note Logic ---
                    temp_fundamental_freqs = []
                    temp_fundamental_mags = []

                    # 1. Peak Width Filtering
                    if len(all_peaks_indices_relative) > 0:
                        try:
                            widths, _, _, _ = peak_widths(magnitudes_filtered, all_peaks_indices_relative, rel_height=0.5)
                            width_filtered_relative_indices = [
                                 idx for i, idx in enumerate(all_peaks_indices_relative)
                                 if widths[i] <= config['max_width_bins']
                            ]
                        except ValueError as e:
                             # print(f"Peak width calculation error: {e}. Skipping width filter.")
                             width_filtered_relative_indices = list(all_peaks_indices_relative)

                        if width_filtered_relative_indices:
                            potential_freqs = xf_filtered[width_filtered_relative_indices]
                            potential_mags = magnitudes_filtered[width_filtered_relative_indices]
                            sorted_local_indices = np.argsort(potential_mags)[::-1] # Strongest first

                            # 2. Harmonic Validation (if enabled)
                            if config['require_harmonics_multi']:
                                confirmed_freqs_intermediate = []
                                confirmed_mags_intermediate = []
                                for i in sorted_local_indices:
                                    fund_freq = potential_freqs[i]
                                    fund_mag = potential_mags[i]
                                    harmonic_count = check_harmonics(fund_freq, fund_mag, all_peaks_indices_relative, magnitudes_filtered, xf_filtered, config)
                                    if harmonic_count >= config['min_harmonic_count_multi']:
                                         is_duplicate = any(abs(fund_freq - ef) < config['min_distance_hz'] for ef in confirmed_freqs_intermediate)
                                         if not is_duplicate:
                                            confirmed_freqs_intermediate.append(fund_freq)
                                            confirmed_mags_intermediate.append(fund_mag)
                                # Use the harmonically validated peaks
                                temp_fundamental_freqs = confirmed_freqs_intermediate
                                temp_fundamental_mags = confirmed_mags_intermediate
                            else: # Skip harmonic check, use width-filtered peaks
                                temp_freqs_width_filtered = []
                                temp_mags_width_filtered = []
                                for i in sorted_local_indices:
                                    fund_freq = potential_freqs[i]
                                    is_duplicate = any(abs(fund_freq - ef) < config['min_distance_hz'] for ef in temp_freqs_width_filtered)
                                    if not is_duplicate:
                                        temp_freqs_width_filtered.append(fund_freq)
                                        temp_mags_width_filtered.append(potential_mags[i])
                                temp_fundamental_freqs = temp_freqs_width_filtered
                                temp_fundamental_mags = temp_mags_width_filtered

                    # --- *** NEW: Limit to Top N Notes *** ---
                    if len(temp_fundamental_freqs) > config['max_simultaneous_notes']:
                        # Sort by magnitude (descending) if not already sorted (they should be from harmonic/width filtering)
                        # Re-sort just to be safe, based on the *final* magnitudes before limiting
                        final_indices_sorted = np.argsort(temp_fundamental_mags)[::-1]
                        
                        # Take only the top N
                        top_n_indices = final_indices_sorted[:config['max_simultaneous_notes']]
                        
                        # Select the corresponding frequencies and magnitudes
                        detected_fundamental_freqs = [temp_fundamental_freqs[i] for i in top_n_indices]
                        detected_fundamental_mags = [temp_fundamental_mags[i] for i in top_n_indices]
                    else:
                        # Fewer than N notes detected, keep them all
                        detected_fundamental_freqs = temp_fundamental_freqs
                        detected_fundamental_mags = temp_fundamental_mags
                    # --- *** End Limit Notes *** ---

                    # For plotting in multi-mode, show the peaks *before* the N-limit?
                    # Or show only the final N peaks? Let's show the final N peaks.
                    plot_peak_freqs = detected_fundamental_freqs
                    plot_peak_mags = detected_fundamental_mags


            # Convert final detected frequencies to note names for this frame
            current_frame_raw_notes = set(filter(None, [frequency_to_note_name(f) for f in detected_fundamental_freqs]))

    # --- Update Plot (Simplified Drawing) ---
    if SHOW_SPECTROGRAM and plot_running and plot_ax is not None and plot_line_spectrum is not None and plot_scatter_peaks is not None:
        try:
            plot_line_spectrum.set_data(xf_filtered, magnitudes_filtered)
            plot_scatter_peaks.set_data(plot_peak_freqs, plot_peak_mags)
            if len(magnitudes_filtered) > 0:
                max_mag = np.max(magnitudes_filtered)
                plot_ax.set_ylim(0, max(max_mag * 1.1, config['min_abs_mag'] * 10))
            else:
                 plot_ax.set_ylim(0, config['min_abs_mag'] * 10)
            plot_fig.canvas.draw_idle()
            plot_fig.canvas.flush_events()
        except Exception as e:
            print(f"Plotting update error: {e}")


# --- Audio Processing Thread ---
def audio_processing_thread(config, mode):
    global latest_confirmed_notes, recent_detections_buffer, current_frame_raw_notes
    global last_heartbeat_time
    global plot_running, plot_fig, plot_ax, plot_line_spectrum, plot_scatter_peaks # plot_bg removed
    global SHOW_SPECTROGRAM # Declare global access

    p = pyaudio.PyAudio()
    stream = None

    # --- Initialize Plot ---
    if SHOW_SPECTROGRAM:
        try:
            plt.ion()
            plot_fig, plot_ax = plt.subplots(figsize=(10, 4))
            plot_ax.set_xlabel("Frequency (Hz)")
            plot_ax.set_ylabel("Magnitude")
            plot_ax.set_xlim(config['min_freq'], config['max_freq'])
            plot_ax.set_ylim(0, 0.1)
            plot_ax.xaxis.set_major_formatter(ticker.FuncFormatter(lambda x, pos: f'{int(x)}'))
            plot_line_spectrum, = plot_ax.plot([], [], 'b-', lw=1)
            plot_scatter_peaks, = plot_ax.plot([], [], 'ro', ms=5)
            plt.show(block=False)
            plot_fig.canvas.flush_events()
        except Exception as e:
             print(f"Failed to initialize spectrogram: {e}. Disabling plot.")
             SHOW_SPECTROGRAM = False

    try:
        stream = p.open(format=FORMAT, channels=CHANNELS, rate=RATE,
                        input=True, frames_per_buffer=CHUNK)
        print(f"\n--- Mode: {mode.upper()} ---")
        print(f"--- Current Settings ---")
        print(f" Max Simultaneous Notes (Multi): {config['max_simultaneous_notes']}")
        print(f" RMS Volume Threshold : {config['min_rms_volume']:.5f}")
        print(f" Peak Prominence Threshold: {config['min_prominence']:.5f}")
        print(f" Peak Abs Mag Threshold: {config['min_abs_mag']:.5f}")
        print(f" Peak Width Max (Bins): {config['max_width_bins']}")
        print(f" Require Harmonics (Multi): {config['require_harmonics_multi']}")
        print(f" Validate Harmonic (Single): {config['validate_single_harmonic']}")
        print("--- ---")
        print("Microphone stream opened. Listening...")

        while plot_running:
            try:
                current_time = time.time()
                if current_time - last_heartbeat_time > HEARTBEAT_INTERVAL:
                    print(f"({time.strftime('%H:%M:%S')}) Still listening...")
                    last_heartbeat_time = current_time

                data = stream.read(CHUNK, exception_on_overflow=False)
                audio_data = np.frombuffer(data, dtype=np.int16)

                # Process the audio chunk (includes plot update)
                process_audio_chunk(audio_data, config, mode)

                # --- Temporal Filtering ---
                recent_detections_buffer.append(current_frame_raw_notes)
                note_counts = {}
                for frame_notes in recent_detections_buffer:
                    for note in frame_notes: note_counts[note] = note_counts.get(note, 0) + 1
                confirmed_notes_in_window = {note for note, count in note_counts.items() if count >= MIN_CONSISTENT_DETECTIONS}
                confirmed_notes_list = sorted(list(confirmed_notes_in_window))

                with data_lock:
                    if latest_confirmed_notes != confirmed_notes_list:
                        notes_str = str(confirmed_notes_list) if confirmed_notes_list else "None"
                        print(f"Confirmed Notes: {notes_str}")
                        if SHOW_SPECTROGRAM and plot_ax and plot_fig:
                            try: plot_ax.set_title(f"Detected Notes: {notes_str}", fontsize=10)
                            except Exception as e: print(f"Plot title update error: {e}")
                        latest_confirmed_notes = confirmed_notes_list

            except IOError as e:
                if e.errno == pyaudio.paInputOverflowed: pass
                else: print(f"Stream read error: {e}"); break
            except Exception as e:
                print(f"Error during audio processing loop: {e}")
                import traceback; traceback.print_exc()
                time.sleep(0.1)

    except Exception as e:
        print(f"Error initializing audio stream: {e}")
    finally:
        plot_running = False
        if stream: stream.stop_stream(); stream.close(); print("Microphone stream closed.")
        p.terminate(); print("PyAudio terminated.")
        if SHOW_SPECTROGRAM and 'plt' in globals():
            try: plt.close('all')
            except: pass
            print("Plot closed.")

# --- Flask Route (Keep as is) ---
@app.route('/notes', methods=['GET'])
def get_notes():
    with data_lock: notes_to_send = latest_confirmed_notes[:]
    return jsonify({"notes": notes_to_send})

# --- Main Execution ---
if __name__ == '__main__':
    while True:
        mode_input = input("Select detection mode: (S)ingle note or (M)ulti-note? ").strip().lower()
        if mode_input == 's': detection_mode = 'single'; print("Single-note mode."); break
        elif mode_input == 'm': detection_mode = 'multi'; print("Multi-note mode."); break
        else: print("Invalid input. Please enter 'S' or 'M'.")

    # --- Configuration - Filters Enabled by Default ---
    config = {
        'min_freq': MIN_FREQUENCY, 'max_freq': MAX_FREQUENCY,
        'min_rms_volume': MIN_RMS_VOLUME,           # Low-ish default
        'min_prominence': MIN_PEAK_PROMINENCE,      # Low-ish default
        'min_abs_mag': MIN_ABSOLUTE_PEAK_MAG,       # Low-ish default

        # --- Filters Enabled ---
        'max_width_bins': MAX_PEAK_WIDTH_BINS_DEFAULT,
        'min_distance_hz': MIN_PEAK_DISTANCE_HZ,
        'require_harmonics_multi': REQUIRE_HARMONICS_MULTI_DEFAULT,
        'validate_single_harmonic': VALIDATE_SINGLE_NOTE_HARMONIC_DEFAULT,

        # --- Other harmonic settings ---
        'min_harmonic_count_multi': MIN_HARMONIC_COUNT_MULTI_DEFAULT,
        'harmonic_tolerance_hz': HARMONIC_SEARCH_TOLERANCE_HZ,
        'harmonic_min_mag_ratio': HARMONIC_MIN_MAG_RATIO,

        # --- New Limit ---
        'max_simultaneous_notes': MAX_SIMULTANEOUS_NOTES,
    }

    for _ in range(TEMPORAL_WINDOW_SIZE): recent_detections_buffer.append(set())

    print("Starting audio processing thread...")
    audio_thread = threading.Thread(target=audio_processing_thread, args=(config, detection_mode), daemon=True)
    audio_thread.start()

    print("Starting Flask server on http://localhost:5000")
    try:
         app.run(host='0.0.0.0', port=5000)
    except KeyboardInterrupt:
         print("\nCtrl+C received, stopping...")
    finally:
         plot_running = False
         if audio_thread.is_alive():
             audio_thread.join(timeout=1.5)
         print("Server stopped.")