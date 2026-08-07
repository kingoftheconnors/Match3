extends Node2D

var is_moving : bool = true

func can_pop() -> bool:
	for i in get_children():
		if i.can_pop() == false:
			return false
	return true

func set_all_pieces_active(flag : bool):
	is_moving = flag

func _physics_process(delta):
	if is_moving:
		for piece in get_children():
			piece.move(delta)

func _process(delta):
	var pieces_to_pop : Array[Node]
	if can_pop():
		for piece in get_children():
			if piece.should_pop():
				pieces_to_pop.append(piece)
	for piece in pieces_to_pop:
		piece.queue_free()

var selected : Node
func click(piece):
	if selected == null:
		selected = piece
		is_moving = false
	elif selected == piece:
		selected = null
		is_moving = true
	else:
		var pos_A = selected.global_position
		var pos_B = piece.global_position
		selected.global_position = Vector2(-1000,0)
		piece.global_position = pos_A
		selected.global_position = pos_B
		selected = null
		is_moving = true
