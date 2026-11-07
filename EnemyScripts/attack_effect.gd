class_name AttackEffect
extends EnemyEffect

@export var damage: int

func do_effect(fight_controller, board) -> bool:
	var completed_effect = super(fight_controller, board)
	if completed_effect:
		return true
	if moves_left <= 0:
		fight_controller.hurt(int(damage), board.get_enemy())
		return true
	return false

func get_current_effect_glyphs(_fight_controller, board) -> Array[TextureRect]:
	var ret : Array[TextureRect] = []
	# Attack glyph
	var intent = create_intent_node(preload("res://IntentGlyphs/Attack.png"))
	var amount_label = Label.new()
	amount_label.text = str(damage)
	amount_label.position = Vector2(32, 32)
	intent.add_child(amount_label)
	intent.tooltip_text = "Deals " + str(damage) + " damage"
	ret.append(intent)
	return ret
