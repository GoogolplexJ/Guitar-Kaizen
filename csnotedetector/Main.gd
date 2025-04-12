extends Node

# Reference to the HTTPRequest node in the scene tree
@onready var note_fetcher: HTTPRequest = $NoteFetcher 
# Reference to the Timer node
@onready var request_timer: Timer = $RequestTimer 

# URL of the Python Flask server
var python_server_url = "http://127.0.0.1:5000/notes" 

# Store the currently detected notes from Python
var current_detected_notes: Array = []

func _ready():
	# Connect the request_completed signal from the HTTPRequest node
	# to a function in this script (_on_note_fetcher_request_completed)
	note_fetcher.request_completed.connect(_on_note_fetcher_request_completed)
	
	# Connect the timer's timeout signal to trigger a new request
	request_timer.timeout.connect(_make_note_request)
	
	print("Godot script ready. Will request notes from:", python_server_url)
	# Optional: Make the first request immediately if the timer has a delay
	# _make_note_request() 

func _make_note_request():
	# Check if a request is already in progress to avoid spamming
	if note_fetcher.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
		# Send a GET request to the Python server
		var error = note_fetcher.request(python_server_url)
		if error != OK:
			printerr("An error occurred in the HTTP request: ", error)
	# else:
		# print("HTTPRequest is busy, skipping request this frame.")


# This function is called automatically when the HTTPRequest completes
func _on_note_fetcher_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		printerr("Note fetch failed! Result code: ", result)
		return

	if response_code == 200:
		# Success! Parse the JSON response
		var json = JSON.new()
		
		# Convert the body (PackedByteArray) to a string
		var response_body_text = body.get_string_from_utf8()
		
		# Parse the string
		var parse_error = json.parse(response_body_text)
		
		if parse_error != OK:
			printerr("Error parsing JSON response: ", json.get_error_message(), " at line ", json.get_error_line())
			return
			
		var response_data = json.get_data()
		
		# Check if the data is a dictionary and has the 'notes' key
		if typeof(response_data) == TYPE_DICTIONARY and response_data.has("notes"):
			# Update the detected notes
			current_detected_notes = response_data["notes"]
			# --- !!! Use the notes in your game here !!! ---
			# Example: Print the notes
			if not current_detected_notes.is_empty():
				print("Received Notes: ", current_detected_notes)
				get_node("NoteDisplayLabel").text = str(current_detected_notes) 
			# Add your game logic: update UI, check against target notes, etc.
			# e.g., get_node("NoteDisplayLabel").text = str(current_detected_notes)
			
		else:
			printerr("Invalid JSON structure received: ", response_body_text)
			
	else:
		printerr("Note fetch request failed with response code: ", response_code)
		# Print body for debugging non-200 responses
		printerr("Response body: ", body.get_string_from_utf8())


# Make sure to stop the timer when the node exits the tree or the game closes
func _exit_tree():
	if request_timer and request_timer.is_connected("timeout", Callable(self, "_make_note_request")):
		request_timer.timeout.disconnect(Callable(self, "_make_note_request"))
	if note_fetcher and note_fetcher.is_connected("request_completed", Callable(self, "_on_note_fetcher_request_completed")):
		note_fetcher.request_completed.disconnect(Callable(self, "_on_note_fetcher_request_completed"))
