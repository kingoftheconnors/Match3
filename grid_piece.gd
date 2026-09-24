extends Sprite2D
class_name grid_piece

var icon : Icon
var grid : Node
var color : Icon.COLOR
func initialize(icon_res : Icon, grid_obj, is_initial_setup : bool = false):
	grid = grid_obj
	icon = icon_res
	texture = icon.texture
	set_color(icon_res.color)
	if !is_initial_setup:
		speed = BASE_SPEED*grid.get_speed_ratio()
func get_color() -> Icon.COLOR:
	return color
func set_color(color_val : Icon.COLOR):
	color = color_val
	$Background.texture = Helpers.get_color_texture(color)

const SLOW_GEN_BASE_SPEED = 150
const BASE_SPEED = 350
const ACCELERATION = 250
var speed = BASE_SPEED
func process_movement(delta, below_piece):
	if grid.is_selected_piece(self):
		global_position = get_global_mouse_position()
		z_index = 1
	elif is_falling():
		if below_piece == null \
			#or grid.is_selected_piece(below_piece) \
			or position.y < below_piece.position.y - grid.get_piece_size().y:
			position.y += delta*speed
			speed += delta*ACCELERATION
	else:
		z_index = 0
		position = get_position_by_grid(grid.find_piece_position(self), grid.get_piece_size())
		speed = BASE_SPEED
func _process(delta):
	if grid.is_selected_piece(self):
		modulate.a = 0.75
	else:
		modulate.a = 1.0

func is_falling() -> bool:
	return get_position_by_grid(grid.find_piece_position(self), grid.get_piece_size()).y > position.y
func force_position_to(grid_position : Vector2i, piece_size : Vector2i):
	position = get_position_by_grid(grid_position, piece_size)
func get_position_by_grid(grid_position : Vector2i, piece_size : Vector2i) -> Vector2i:
	return Vector2i(grid_position.x*piece_size.x+piece_size.x/2, grid_position.y*-piece_size.y-piece_size.y/2 + grid.board_size.y*piece_size.y)

var popped : bool = false
func mark_popped():
	popped = true
func is_popped() -> bool:
	return popped
