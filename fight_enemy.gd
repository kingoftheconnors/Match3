extends Node2D

var max_health : int = 100
var enemy : Enemy
@export var board : NodePath
var fight_controller : level

# Called when the node enters the scene tree for the first time.
func setup(e : Enemy) -> void:
	enemy = e.duplicate()
	$EnemyHealth.max_value = e.health
	enemy._init()
	update_hud()

func block(amo):
	enemy.block(amo)
	update_hud()
func get_block() -> int:
	return enemy.get_block()
func hurt(amo):
	enemy.hurt(amo, fight_controller, get_node(board))
	update_hud()
func get_health() -> int:
	return enemy.health
func get_gold() -> int:
	return enemy.gold

func on_move_used():
	enemy.on_move_used(fight_controller, get_node(board))
	update_hud()
func on_move_completed():
	enemy.on_move_completed(fight_controller, get_node(board))
	update_hud()

func on_icon_popped(icon: Icon, icon_pos: Vector2i) -> void:
	enemy.on_icon_popped(fight_controller, get_node(board), icon, icon_pos)

func _process(delta: float) -> void:
	if get_node(board).is_settling():
		update_hud()

func update_hud():
	for i in $IntentGlyphs.get_children():
		i.queue_free()
	for rect in enemy.get_glyphs(fight_controller, get_node(board)):
		$IntentGlyphs.add_child(rect)
	$EnemyHealth.value = enemy.health
	$Gold.text = str(enemy.gold)
	$EnemyHealth/Label.text = str(int(enemy.health)) + "/" + str(int(enemy.max_health))
	if enemy.get_block() > 0:
		$EnemyHealth/Shield.visible = true
		$EnemyHealth/Shield/Label.text = str(enemy.get_block())
		$EnemyHealth.modulate = Color.CADET_BLUE
	else:
		$EnemyHealth/Shield.visible = false
		$EnemyHealth.modulate = Color.RED
