extends Sprite2D
class_name grid_piece

var icon : Icon
var grid : Node
func initialize(icon_res : Icon, grid_obj, is_initial_setup : bool = false):
	grid = grid_obj
	icon = icon_res.duplicate()
	if icon.texture:
		texture = icon.texture
	set_icon_color(icon_res.color)
	if !is_initial_setup:
		speed = BASE_SPEED*grid.get_speed_ratio()
	icon._init()
func get_color() -> Icon.COLOR:
	return icon.color
func get_material_type() -> Icon.MATERIAL:
	return icon.material
func set_icon_color(color_val : Icon.COLOR):
	icon.color = color_val
	$Background.texture = Icon.get_color_texture(color_val)
func set_icon_material(material_val : Icon.MATERIAL):
	icon.material = material_val
func transmute(to_color : Icon.COLOR, to_material : Icon.MATERIAL):
	if to_color != Icon.COLOR.NONE:
		set_icon_color(to_color)
	if to_material != Icon.MATERIAL.NONE:
		set_icon_material(to_material)

const SLOW_GEN_BASE_SPEED = 150
const BASE_SPEED = 350
const ACCELERATION = 250
var speed = BASE_SPEED
func process_movement(delta, below_piece):
	if name == "@Sprite2D@57":
		pass
	if is_selected_piece:
		global_position = get_global_mouse_position()
		z_index = 1
	elif is_falling():
		if below_piece == null \
			or position.y < below_piece.position.y - grid.get_piece_size().y:
			position.y += delta*speed
			speed += delta*ACCELERATION
	else:
		z_index = 0
		position = get_position_by_grid(grid.find_piece_position(self), grid.get_piece_size())
		speed = BASE_SPEED
var is_selected_piece : bool
func set_is_selected_piece(flag : bool):
	is_selected_piece = flag
	if flag:
		modulate.a = 0.75
	else:
		modulate.a = 1.0

func move_used(fight_controller, board, this_pos : Vector2i):
	icon.move_used(fight_controller, board, this_pos)
func move_completed(fight_controller, board, this_pos : Vector2i):
	icon.move_completed(fight_controller, board, this_pos)
func icon_popped(fight_controller, board, popped_pos : Vector2i, this_pos : Vector2i):
	icon.icon_popped(fight_controller, board, popped_pos, grid, this_pos)

func is_falling() -> bool:
	return get_position_by_grid(grid.find_piece_position(self), grid.get_piece_size()).y > position.y
# Method that checks whether the icon has fallen far enough to be visible
func is_on_board() -> bool:
	return position.y >= 0
func force_position_to(grid_position : Vector2i, piece_size : Vector2i):
	position = get_position_by_grid(grid_position, piece_size)
func get_position_by_grid(grid_position : Vector2i, piece_size : Vector2i) -> Vector2i:
	return Vector2i(grid_position.x*piece_size.x+piece_size.x/2, grid_position.y*-piece_size.y-piece_size.y/2 + grid.board_size.y*piece_size.y)

var popped : bool = false
func mark_popped():
	popped = true
func is_popped() -> bool:
	return popped
