extends Sprite2D
class_name grid_piece

enum PIECE_TYPE {
	WHITE, RED, BLUE, GREEN, YELLOW, ORANGE, PURPLE, POPPED,
	AD,AD2,NEWSLETTER,PHISHING,VIRUS,DATA,CONTACT,SUPPORT_TICKET,APPLICANT,BUG,BACTERIA,EMAIL,HOUSE,HTML,ANALYTICS,BILL
}
var type : PIECE_TYPE
var grid : Node
func initialize(piece_type : PIECE_TYPE, grid_obj, is_initial_setup : bool = false):
	grid = grid_obj
	type = piece_type
	if !is_initial_setup:
		speed = BASE_SPEED*grid.get_speed_ratio()
	match piece_type:
		PIECE_TYPE.WHITE:
			modulate = Color.WHITE
		PIECE_TYPE.RED:
			modulate = Color.RED
		PIECE_TYPE.BLUE:
			modulate = Color.BLUE
		PIECE_TYPE.GREEN:
			modulate = Color.GREEN
		PIECE_TYPE.YELLOW:
			modulate = Color.YELLOW
		PIECE_TYPE.ORANGE:
			modulate = Color.ORANGE
		PIECE_TYPE.PURPLE:
			modulate = Color.PURPLE
		_:
			modulate = Color.TRANSPARENT
func get_type() -> PIECE_TYPE:
	return type

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
	return Vector2i(grid_position.x*piece_size.x+piece_size.x/2, grid_position.y*-piece_size.y-piece_size.y/2)

var popped : bool = false
func mark_popped():
	popped = true
func is_popped() -> bool:
	return popped
