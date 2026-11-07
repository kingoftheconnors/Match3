class_name DefendEffect
extends EnemyEffect

@export var block: int

func enter(fight_controller, board):
	fight_controller.enemy_block(block, board.get_enemy())

func do_effect(fight_controller, board) -> bool:
	var completed_effect = super(fight_controller, board)
	if completed_effect:
		return true
	if moves_left <= 0:
		return true
	return false
