extends ColorRect

@export var level_controller : NodePath
@export var match_grids : Array[NodePath]

func _process(delta):
	if get_parent().moves == 0:
		var is_settling = false
		for i in match_grids:
			if get_node(i).is_settling() or get_node(i).has_poppable_groups():
				is_settling = true
		if !is_settling:
			show_stats()
	if get_node(level_controller).get_progress() >= 1.0:
		show_stats()
	if get_node(level_controller).get_failures() >= get_parent().failures_to_lose:
		get_parent().game_lost = true
		show_stats()

func show_stats():
	$VBoxContainer/Stars.value = 0
	visible = true
	# Completion
	var progress = get_node(level_controller).get_progress()
	$VBoxContainer/Completion.max_value = get_parent().goals_to_win
	$VBoxContainer/Completion.value = progress*get_parent().goals_to_win
	if progress >= 1.0:
		$VBoxContainer/Stars.value += 1
		# Efficiency
		$VBoxContainer/Efficiency.max_value = get_parent().efficiency_goal
		$VBoxContainer/Efficiency.value = get_parent().moves
		if get_parent().moves >= get_parent().efficiency_goal:
			$VBoxContainer/Stars.value += 1
		# Security
		#$VBoxContainer/Security.value = $VBoxContainer/Security.max_value
		#$VBoxContainer/Stars.value += 1
