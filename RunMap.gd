extends Node2D

func _ready() -> void:
	var index = 0
	for f in SaveManager.fights:
		var fight_obj = preload("res://map_fight_btn.tscn").instantiate()
		fight_obj.position = Vector2(500 - index*100, 480)
		fight_obj.fight = f
		get_parent().add_child(fight_obj)
		index += 1
