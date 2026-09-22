extends Node

var current_level : int = 0
var fights : Array[Fight] = []
var current_position : int = 0
var max_health : int = 100
var health : int = 100
var bag : Array[Icon] = []
var gold : int = 0
var relics : Array = []

## Saves game data, including progress and collectibles
func save_game():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	# Store the save dictionary as a new line in the save file.
	save_file.store_line(JSON.stringify({
		current_level = current_level,
		fights = fights,
		current_position = current_position,
		max_health = max_health,
		health = health,
		bag = bag,
		gold = gold,
		relics = relics,
	}))
	save_file.close()

func goto_level(entering_level = 0):#, depth = 5):
	current_level = entering_level
	fights = []
	if FileAccess.file_exists("user://savegame.save"):
		load_game()
	else:
		# Generate map
		var fight_paths = ResourceLoader.list_directory("res://Battles/")
		var all_fights : Array[Fight] = []
		for f in fight_paths:
			all_fights.append(load("res://Battles/" + f))
		var boss_fights = all_fights.filter(func(f): return f.is_boss)
		var regular_fights = all_fights.filter(func(f): return !f.is_boss and f.appears_on_levels.has(current_level))
		fights.append(boss_fights[randi() % len(boss_fights)])
		fights.append(regular_fights[randi() % len(regular_fights)])

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
		current_level = node_data["current_level"]
		fights = node_data["fights"]
		current_position = node_data["current_position"]
		max_health = node_data["max_health"]
		health = node_data["health"]
		bag = node_data["bag"]
		gold = node_data["gold"]
		relics = node_data["relics"]
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	save_file.close()
	data_loaded = true

func clear_data():
	fights = []
	current_position = 0
	bag = []
	gold = 0
	relics = []

func is_save_exists():
	return FileAccess.file_exists("user://savegame.save")
var data_loaded : bool = false
func is_data_loaded():
	return data_loaded

func query_relics_on_pop():
	pass
func hurt(amo : int):
	health -= amo
	emit_signal("health_changed")
func heal(amo : int):
	health += amo
	emit_signal("health_changed")
func earn_gold(amo : int):
	gold += amo
	emit_signal("gold_changed")

signal health_changed
signal gold_changed
