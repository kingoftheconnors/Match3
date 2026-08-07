extends ColorRect

@export var level_controller : NodePath
@export var match_grids : Array[NodePath]

func _process(delta):
	if get_parent().moves == 0:
		for i in match_grids:
			if get_node(i).is_settling():
				return
		show_stats()
	if get_node(level_controller).get_progress() >= get_parent().goals_to_win:
		show_stats()
	if get_node(level_controller).get_failures() >= get_parent().failures_to_lose:
		show_stats()

func show_stats():
	$VBoxContainer/Stars.value = 0
	visible = true
	# Completion
	var progress = get_node(level_controller).get_progress()
	$VBoxContainer/Completion.max_value = get_parent().goals_to_win
	$VBoxContainer/Completion.value = progress
	$VBoxContainer/Completion/Completion2.max_value = get_parent().super_performance_goal
	$VBoxContainer/Completion/Completion2.value = progress
	if $VBoxContainer/Completion.value >= get_parent().super_performance_goal:
		$VBoxContainer/Stars.value += 1
	if progress >= get_parent().goals_to_win:
		$VBoxContainer/Stars.value += 1
	# Efficiency
	$VBoxContainer/Efficiency.max_value = get_parent().efficiency_goal
	$VBoxContainer/Efficiency.value = get_parent().moves
	if get_parent().moves >= get_parent().efficiency_goal:
		$VBoxContainer/Stars.value += 1
	# Security
	$VBoxContainer/Security.value = $VBoxContainer/Security.max_value
	$VBoxContainer/Stars.value += 1
