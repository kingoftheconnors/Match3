extends Node2D
class_name level

@export var piece_types : Array[grid_piece.PIECE_TYPE]
@export var internet_piece_types : Array[grid_piece.PIECE_TYPE]
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
@export var is_internet_active : bool = true
@export var num_refreshes : int = 3
@export var is_slow_generation : bool = false
@export var goal_minimum_pop_size : int = 3
@export var spam_minimum_pop_point_counts : int = 3

const PROGRESS_COLORS = [
	Color("#00FA39"),
	Color("#00FA8C"),
	Color.SEA_GREEN,
	Color.LIGHT_GREEN,
	Color.GREEN_YELLOW,
]
const OBSTACLE_COLOR = Color.RED
const POPPABLES_COLORS = [
	Color.YELLOW,
	Color.ORANGE,
	Color.SANDY_BROWN,
]
const EXTRAS_COLORS = [
	Color("#D4E5FA"),
	Color("#EDF7FA"),
	Color("#D5DAFA"),
	Color("#EDFAF9"),
	Color("#DCD4FA"),
	Color("#EDF3FA"),
	Color("#D4F1FA"),
	Color("#EDFAF5"),
	Color("#E8D4FA"),
	Color("#EDEFFA"),
	Color("#C3BCFA"),
	Color("#BBC8FA"),
	Color("#D7BBFA"),
	Color("#B1E3FA"),
	Color("#B1CCFA"),
]

func remove_type(type : grid_piece.PIECE_TYPE):
	if piece_types.has(type):
		piece_types.erase(type)
	if internet_piece_types.has(type):
		internet_piece_types.erase(type)

var game_lost : bool = false
func is_game_active():
	return (moves > 0 or flow > 0 \
		or $Office.has_poppable_groups() \
		or $Internet.has_poppable_groups()) and game_lost == false

var combo_level : int = 0
func _on_combo_level_increased():
	combo_level += 1
	if combo_level in [2, 4, 7, 11, 15, 21, 28, 36, 45, 55, 66, 78, 91]:
		flow += 1
		emit_signal("flow_increased", flow)
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

signal flow_increased(flow : int)
signal flow_reset
