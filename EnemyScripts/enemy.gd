class_name Enemy
extends Resource

@export var health: int
@export var gold: int
@export var enemy_bag: Array[Icon]
@export var texture : Texture2D
@export var intermove_effects: Array[EnemyEffect]

var block_val : int = 0
var max_health : int

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init():
	max_health = health
	if len(intermove_effects) > 0:
		intermove_effects[0].reset()

func block(amo):
	block_val += amo
func get_block() -> int:
	return block_val
func hurt(amo, fight_controller, board):
	if block_val >= amo:
		block_val -= amo
	else:
		var health_lost = (amo - block_val)
		block_val = 0
		health = health - health_lost
		if len(intermove_effects) > 0:
			intermove_effects[effect_phase].mark_damage(health_lost, fight_controller, board)

var effect_phase : int = 0
func on_move_used(fight_controller, board):
	pass
func on_move_completed(fight_controller, board):
	if len(intermove_effects) > 0:
		var effect_complete = intermove_effects[effect_phase].do_effect(fight_controller, board)
		if effect_complete:
			intermove_effects[effect_phase].reset()
			effect_phase = wrapi(effect_phase+1, 0, len(intermove_effects))

func on_icon_popped(fight_controller, board, icon: Icon, icon_pos: Vector2i):
	pass

func get_glyphs(fight_controller, board) -> Array[TextureRect]:
	if len(intermove_effects) > 0:
		return intermove_effects[effect_phase].get_effect_glyphs(fight_controller, board)
	else:
		return []
