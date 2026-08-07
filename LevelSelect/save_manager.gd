extends Node

var completed_levels : Array = []

func level_completed(tag):
	completed_levels.push_back(tag)
	save_game()
func is_level_completed(tag) -> bool:
	for i in completed_levels:
		if (i == tag):
			return true
	return false
func last_level_completed(challenge_tag):
	if completed_levels.size() > 0:
		return completed_levels.back()
	return null

## Saves game data, including progress and collectibles
func save_game():
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	# Store the save dictionary as a new line in the save file.
	save_game.store_line(JSON.stringify({
		levels = completed_levels
	}))
	save_game.close()

func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	var json_string = save_file.get_line()
	var json = JSON.new()
	# Check if there is any error while parsing the JSON string, skip in case of failure
	var parse_result = json.parse(json_string)
	if parse_result == OK:
		var node_data = json.get_data()
		completed_levels = node_data["levels"]
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	save_file.close()
	data_loaded = true

func clear_data():
	completed_levels = []

func is_save_exists():
	return FileAccess.file_exists("user://savegame.save")
var data_loaded : bool = false
func is_data_loaded():
	return data_loaded
