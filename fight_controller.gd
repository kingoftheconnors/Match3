extends Node2D
class_name level

@export var bag : Array[Icon]
var block_val : int = 0

func initialize(fight : Fight):
	bag = SaveManager.bag.duplicate()
	for e in fight.enemies:
		bag.append_array(e.enemy_bag)
		$Enemy.setup(e.health, e.gold)

func check_for_victory_or_defeat():
	if $Enemy.health <= 0:
		$Office.process_mode = Node.PROCESS_MODE_DISABLED
		var gold_collection_percentage = 0.2
		$VictoryWindow.show_victory_dialog(int($Enemy.gold * gold_collection_percentage))
	if SaveManager.health <= 0:
		$Office.process_mode = Node.PROCESS_MODE_DISABLED
		$DefeatWindow.visible = true

func remove_type(icon : Icon):
	if bag.has(icon):
		bag.erase(icon)

var game_lost : bool = false
func is_game_active():
	return game_lost == false

var combo_level : int = 0
func _on_combo_level_increased():
	combo_level += 1
func _on_combo_level_reset():
	if $Office.is_settling() == false:
		if combo_level != 0:
			combo_level = 0

func _on_move_used():
	pass

func block(amo):
	block_val += amo
	emit_signal("block_changed")
func get_block() -> int:
	return block_val
func enemy_block(amo):
	$Enemy.block(amo)
func damage(amo):
	$Enemy.hurt(amo)
	check_for_victory_or_defeat()
func hurt(amo):
	if block_val >= amo:
		block_val -= amo
		emit_signal("block_changed")
	else:
		block_val = 0
		SaveManager.hurt(amo - block_val)
	check_for_victory_or_defeat()

signal block_changed
