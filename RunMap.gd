extends Node2D

func _ready() -> void:
	var index = 0
	for f in SaveManager.fights:
		var fight_obj = preload("res://map_fight_btn.tscn").instantiate()
		fight_obj.position = Vector2(100 + index*300, 300)
		fight_obj.fight = f
		add_child(fight_obj)
		index += 1
