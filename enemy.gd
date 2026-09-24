class_name Enemy
extends Resource

enum INTERMOVE_EFFECT {
	NONE,
	ATTACK,
	MUTATE_TO_ICON,
}

@export var health: int
@export var gold: int
@export var enemy_bag: Array[Icon]
@export var texture : Texture2D
@export var intermove_effect: INTERMOVE_EFFECT
# TODO: Overridng exporting to make "intermove values" dynamic based on type chosen
@export var intermove_value: String

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init():
	pass
