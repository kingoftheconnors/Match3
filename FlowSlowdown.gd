extends Node

func _process(delta):
	if get_parent().flow > 0 and !Input.is_action_pressed("slowdown"):
		Engine.time_scale = 0.25
	else:
		Engine.time_scale = 1.0
