extends CharacterBody2D
#class_name piece

enum PIECE_TYPE {WHITE, RED, BLUE, GREEN, YELLOW, ORANGE, PURPLE}
@export var piece_type : PIECE_TYPE

func _process(delta):
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

const FALL_SPEED = 1000
func move(delta):
	velocity.y += 100*delta
	move_and_slide()
	if !is_on_floor():
		velocity.y = FALL_SPEED

func can_pop() -> bool:
	return is_on_floor()

func should_pop(checked_nodes : Array = []) -> bool:
	var total_match = 0
	checked_nodes.append(self)
	for piece in adjacent_pieces:
		if piece.piece_type == piece_type:
			total_match += 1
	if total_match >= 2:
		return true
	# Test nearby pieces to see if they're poppable
	for piece in adjacent_pieces:
		if piece.piece_type == piece_type:
			if not piece in checked_nodes and piece.should_pop(checked_nodes):
				return true
	return false

var adjacent_pieces : Array
func _on_area_2d_body_entered(body):
	if body not in adjacent_pieces and body != self:
		adjacent_pieces.append(body)
func _on_area_2d_body_exited(body):
	if body in adjacent_pieces:
		adjacent_pieces.erase(body)

var tween : Tween
var is_hovered : bool = false
func _on_mouse_area_mouse_entered():
	is_hovered = true
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property($ColorRect, "scale", Vector2.ONE*1.1, .2)
func _on_mouse_area_mouse_exited():
	is_hovered = false
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property($ColorRect, "scale", Vector2.ONE*1, .2)
func _on_mouse_area_input_event(viewport, event : InputEvent, shape_idx):
	if event.is_action_pressed("click"):
		get_parent().click(self)
