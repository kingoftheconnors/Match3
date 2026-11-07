class_name MutateEffect
extends EnemyEffect

@export var from_color : Icon.COLOR
@export var from_material : Icon.MATERIAL
@export var to_color : Icon.COLOR
@export var to_material : Icon.MATERIAL
@export var amount : int = 1

func do_effect(fight_controller, board) -> bool:
	var completed_effect = super(fight_controller, board)
	if completed_effect:
		return true
	if moves_left <= 0:
		board.transmute_random(amount, from_color, from_material, to_color, to_material)
		return true
	return false

func get_current_effect_glyphs(fight_controller, board) -> Array[TextureRect]:
	var ret : Array[TextureRect] = []
	# Attack glyph
	var intent = create_intent_node(preload("res://IntentGlyphs/Swap.png"))
	if amount < 100:
		var amount_label = Label.new()
		amount_label.text = str(amount)
		amount_label.position = Vector2(32, 32)
		intent.add_child(amount_label)
	var tooltip = ""
	if from_material != Icon.MATERIAL.NONE and from_color != Icon.MATERIAL.NONE:
		tooltip = "Transmutes " + Icon.COLOR_NAME(from_color) + " " + Icon.MATERIAL_NAME(from_material) + "s"
	elif from_material != Icon.MATERIAL.NONE:
		tooltip = "Transmutes " + Icon.MATERIAL_NAME(from_material) + "s"
	elif from_color != Icon.MATERIAL.NONE:
		tooltip = "Transmutes " + Icon.COLOR_NAME(from_color) + " icons"
	
	if to_material != Icon.MATERIAL.NONE and to_color != Icon.MATERIAL.NONE:
		tooltip += " to " + Icon.COLOR_NAME(to_color) + " " + Icon.MATERIAL_NAME(to_material) + "s"
	elif to_material != Icon.MATERIAL.NONE:
		tooltip += " to " + Icon.MATERIAL_NAME(to_material) + "s"
	elif to_color != Icon.MATERIAL.NONE:
		tooltip += " to " + Icon.COLOR_NAME(to_color)
	
	intent.tooltip_text = tooltip
	ret.append(intent)
	return ret
