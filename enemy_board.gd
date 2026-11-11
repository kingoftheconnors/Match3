extends Node2D

func initialize(fight_controller : level, enemy : Enemy, bag : Array[Icon]):
	$Office.connect("move_completed", fight_controller._on_move_completed)
	$Office.connect("icon_popped", fight_controller._on_icon_popped)
	$Office.fight_controller = fight_controller
	$Office.bag = bag
	$Enemy.fight_controller = fight_controller
	$Enemy.setup(enemy)

func get_health() -> int:
	return $Enemy.get_health()

func get_gold() -> int:
	return $Enemy.get_gold()

func set_board_size(size : Vector2i):
	$Office.set_board_size(size)

func on_move_used():
	$Enemy.on_move_used()
	$Office.on_move_used()
func on_move_completed() -> void:
	$Enemy.on_move_completed()
	$Office.on_move_completed()
func on_icon_popped(icon: Icon, icon_pos: Vector2i, board) -> void:
	$Enemy.on_icon_popped(icon, icon_pos)
	$Office.on_icon_popped(icon, icon_pos, board)
func get_selected_piece() -> grid_piece:
	return $Office.get_selected_piece()
func is_settling() -> bool:
	return $Office.is_settling()
func get_piece_at_global_pos(global_position) -> grid_piece:
	return $Office.get_piece_at_global_pos(global_position)
func pop_matches():
	return $Office.pop_matches()

enum SIZE {
	LARGE,
	MEDIUM,
	SMALL
}

func set_size(size : SIZE):
	match size:
		SIZE.LARGE:
			$Enemy.position.x = 175
			$Office.size.x = 498
			$Office.position.x = -498
		SIZE.MEDIUM:
			$Enemy.position.x = 175
			$Office.size.x = 300
			$Office.position.x = -300
		SIZE.SMALL:
			$Enemy.position.x = 120
			$Office.size.x = 200
			$Office.position.x = -200
		_:
			$Enemy.position.x = 120
			$Office.size.x = 200
			$Office.position.x = -200
