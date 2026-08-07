extends Node2D
class_name level

@export var piece_types : Array[grid_piece.PIECE_TYPE]
@export var goals : Array[grid_piece.PIECE_TYPE]
@export var obstacles : Array[grid_piece.PIECE_TYPE]
@export var poppables : Array[grid_piece.PIECE_TYPE]

@export var moves : int = 10
@export var flow : int = 0
@export var efficiency_goal : int = 5
@export var failures_to_lose : int
@export var goals_to_win : int
@export var super_performance_goal : int = 100
@export var matches_to_pop : int

const PROGRESS_COLOR = Color.GREEN
const OBSTACLE_COLOR = Color.RED
const POPPABLES_COLORS = [
	Color.YELLOW,
	Color.ORANGE,
	Color.SANDY_BROWN,
]

func remove_type(type : grid_piece.PIECE_TYPE):
	piece_types.erase(type)

func is_game_active():
	return moves > 0 or flow > 0

var combo_level : int = 0
func _on_combo_level_increased():
	combo_level += 1
	if combo_level in [3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377]:
		flow += 1
		$FlowLeft.update_text(flow)
func _on_combo_level_reset():
	if $Office.is_settling() == false and $Internet.is_settling() == false:
		if combo_level != 0:
			emit_signal("flow_reset")
			combo_level = 0
			flow = 0
			$FlowLeft.update_text(flow)

func _on_move_used():
	if flow > 0:
		flow -= 1
		$FlowLeft.update_text(flow)
	else:
		moves -= 1
		$"Computer back4/MovesLeft".update_text(moves)

signal flow_reset
