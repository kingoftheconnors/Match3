class_name EnemyEffect
extends Resource

@export var delay: int
var moves_left = delay

@export var damage_to_replace : int
var current_damage_to_replace : int
@export var replace_effect : EnemyEffect

func mark_damage(amount : int, fight_controller, board):
	if damage_to_replace > 0 and current_damage_to_replace > 0:
		current_damage_to_replace -= amount
		if current_damage_to_replace <= 0:
			replace_effect.enter(fight_controller, board)
func enter(fight_controller, board):
	pass

func reset():
	moves_left = delay
	current_damage_to_replace = damage_to_replace
	if damage_to_replace > 0:
		replace_effect.reset()

func do_effect(fight_controller, board) -> bool:
	if damage_to_replace > 0 and current_damage_to_replace <= 0:
		return replace_effect.do_effect(fight_controller, board)
	moves_left -= 1
	return false

func get_effect_glyphs(fight_controller, board) -> Array[TextureRect]:
	if damage_to_replace > 0 and current_damage_to_replace <= 0:
		return replace_effect.get_effect_glyphs(fight_controller, board)
	var ret : Array[TextureRect] = []
	# Delay glyphs
	for i in range(moves_left-1):
		ret.append(create_intent_node())
	ret.append_array(get_current_effect_glyphs(fight_controller, board))
	return ret

func get_current_effect_glyphs(fight_controller, board) -> Array[TextureRect]:
	return [create_intent_node()]

func create_intent_node(texture : Texture = preload("res://IntentGlyphs/DoNothing.png")) -> TextureRect:
	var intent = TextureRect.new()
	intent.texture = texture
	intent.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	return intent
