class_name Relic
extends Resource

@export var name : String
@export var classification : String
@export var description : String
@export var rarity : int = 0
@export var cost : int = 0

func _init():
	pass

func icon_popped(fight_controller, board, popped_pos : Vector2i, this_board, this_pos : Vector2i):
	pass

func move_used(fight_controller, board, this_pos : Vector2i):
	pass

# TODO: HIDDEN PROPERTY: ADD SPECIAL EXPORT WHEN MATERIAL IS ICE
var pops_after_x_moves : int = 3
func move_completed(fight_controller, board, this_pos : Vector2i):
	pass
