class_name AttackByMaterialEffect
extends EnemyEffect

@export var material : Icon.MATERIAL

func get_damage(board) -> int:
	return board.get_amount_of_material(material)

func do_effect(fight_controller, board) -> bool:
	var completed_effect = super(fight_controller, board)
	if completed_effect:
		return true
	if moves_left <= 0:
		fight_controller.hurt(get_damage(board), board.get_enemy())
		return true
	return false

func get_current_effect_glyphs(_fight_controller, board) -> Array[TextureRect]:
	var ret : Array[TextureRect] = []
	# Attack glyph
	var intent = create_intent_node(preload("res://IntentGlyphs/Attack.png"))
	var amount_label = Label.new()
	amount_label.text = str(get_damage(board))
	amount_label.position = Vector2(32, 32)
	intent.add_child(amount_label)
	intent.tooltip_text = "Deals " + str(get_damage(board)) + " damage based on amount of " + str(material) + " on board"
	ret.append(intent)
	return ret
