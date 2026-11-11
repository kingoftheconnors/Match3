extends TextureRect

var mat : Icon.MATERIAL
var bag_pieces : Node
signal material_applied_to_bag(color : Icon.MATERIAL)

var is_held : bool = false
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			is_held = true
		else:
			is_held = false
			var piece = bag_pieces.get_piece_at_global_position(get_global_mouse_position())
			if piece:
				piece.set_icon_material(mat)
				emit_signal("material_applied_to_bag", mat)

func _process(delta: float) -> void:
	if is_held:
		offset_transform_position = get_global_mouse_position() - global_position - Vector2(32,32)
	else:
		offset_transform_position = Vector2.ZERO
