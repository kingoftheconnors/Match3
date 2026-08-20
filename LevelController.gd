extends Control

var level_progress := {}
var gameover_progress : Control
var poppable_progress := {}

signal type_popped(type : grid_piece.PIECE_TYPE)

func _ready():
	for type in get_parent().goals:
		$VBoxContainer/Progress.visible = true
		var progress = preload("res://progress_bar.tscn").instantiate()
		var index = get_parent().goals.find(type)
		progress.modulate = level.PROGRESS_COLORS[index]
		progress.max_value = get_parent().goals_to_win
		progress.custom_minimum_size.x = get_progress_bar_size(progress.max_value)
		$VBoxContainer/Progress/HFlowContainer.add_child(progress)
		level_progress[type] = progress
	if get_parent().obstacles.size() > 0:
		$VBoxContainer/Mistakes.visible = true
		gameover_progress = preload("res://progress_bar.tscn").instantiate()
		gameover_progress.modulate = level.OBSTACLE_COLOR
		gameover_progress.max_value = get_parent().failures_to_lose
		gameover_progress.custom_minimum_size.x = get_progress_bar_size(gameover_progress.max_value)
		$VBoxContainer/Mistakes/HFlowContainer.add_child(gameover_progress)
	for type in get_parent().poppables:
		$VBoxContainer/Spam.visible = true
		var progress = preload("res://progress_bar.tscn").instantiate()
		var index = get_parent().poppables.find(type)
		progress.modulate = level.POPPABLES_COLORS[index]
		progress.max_value = get_parent().matches_to_pop
		progress.custom_minimum_size.x = get_progress_bar_size(progress.max_value)
		$VBoxContainer/Spam/HFlowContainer.add_child(progress)
		poppable_progress[type] = progress

func get_progress_bar_size(val):
	return min(250, 250*val/50.0)

func _on_match_3_grid_icon_popped(type : grid_piece.PIECE_TYPE, group_size : int):
	if type in get_parent().goals:
		level_progress[type].value += 1
	if type in get_parent().obstacles:
		gameover_progress.value += 1
	if get_parent().poppables.has(type) and group_size >= get_parent().spam_minimum_pop_point_counts:
		poppable_progress[type].value += 1
		if poppable_progress[type].value >= poppable_progress[type].max_value:
			emit_signal("type_popped", type)

func get_progress() -> float:
	var total : float = 0.0
	for type in get_parent().goals:
		total += level_progress[type].value
	return total / (get_parent().goals_to_win*get_parent().goals.size())
func get_failures() -> int:
	if gameover_progress != null:
		return gameover_progress.value
	return 0
