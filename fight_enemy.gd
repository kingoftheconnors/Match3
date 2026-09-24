extends Node2D

var gold : int
var health : int = 100
var max_health : int = 100
var block_val : int = 0

# Called when the node enters the scene tree for the first time.
func setup(health_val : int, gold_val) -> void:
	health = health_val
	max_health = health_val
	gold = gold_val
	$EnemyHealth.max_value = health_val
	update_hud()

func block(amo):
	block_val += amo
	update_hud()
func get_block() -> int:
	return block_val
func hurt(amo):
	if block_val >= amo:
		block_val -= amo
		update_hud()
	else:
		block_val = 0
		health = health - (amo - block_val)
		update_hud()

func update_hud():
	$EnemyHealth.value = health
	$Gold.text = str(gold)
	$EnemyHealth/Label.text = str(int(health)) + "/" + str(int(max_health))
	if block_val > 0:
		$EnemyHealth/Shield.visible = true
		$EnemyHealth/Shield/Label.text = str(block_val)
		$EnemyHealth.modulate = Color.CADET_BLUE
	else:
		$EnemyHealth/Shield.visible = false
		$EnemyHealth.modulate = Color.RED
