extends Node2D

func _ready() -> void:
	var index = 0
	for f in SaveManager.fights:
		var fight_obj = preload("res://map_fight_btn.tscn").instantiate()
		fight_obj.connect("pressed", $CanvasLayer2/Bag.hide)
		fight_obj.position = Vector2(100 + index*150, 600-index*100)
		fight_obj.fight = f
		add_child(fight_obj)
		index += 1
