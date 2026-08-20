extends Node

func _input(event):
	if event.is_action_pressed("slowdown") and get_parent().flow > 0:
		Engine.time_scale = 0.25
	if event.is_action_released("slowdown"):
		Engine.time_scale = 1.0

func reset_slowdown():
	Engine.time_scale = 1.0

func _on_level_flow_increased(flow):
	if Input.is_action_pressed("slowdown"):
		Engine.time_scale = 0.25
