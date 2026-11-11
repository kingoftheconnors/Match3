extends Panel

@export var board_size : Vector2i = Vector2i(6,6)

func open():
	for i in get_children():
		i.queue_free()
	var x : int = 0
	var y : int = 0
	for i in SaveManager.bag:
		var new_piece = preload("res://grid_piece.tscn").instantiate()
		new_piece.initialize(i, self, true, true)
		new_piece.position = Vector2(x*get_piece_size().x+get_piece_size().x/2, y*get_piece_size().y+get_piece_size().x/2)
		x += 1
		if x >= board_size.x:
			x = 0
			y += 1
		add_child(new_piece)

func get_piece_size() -> Vector2i:
	return Vector2(size.x/board_size.x, size.y/board_size.y)

func get_piece_at_global_position(pos) -> grid_piece:
	for i in get_children():
		if abs(i.global_position.x - pos.x) < 32 and abs(i.global_position.y - pos.y) < 32:
			return i
	return null
