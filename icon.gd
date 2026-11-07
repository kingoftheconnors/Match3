class_name Icon
extends Resource

enum POP_TYPE {
	GROUP,
	LINE,
}

enum MATERIAL {
	NONE,
	BASIC_GEM,
	BASIC_METAL,
	ICE,
	WOOD,
	GLASS,
	BASIC_BLOCK,
}
static func MATERIAL_NAME(mat : MATERIAL) -> String:
	match mat:
		MATERIAL.BASIC_GEM:
			return "GEM"
		MATERIAL.BASIC_METAL:
			return "METAL"
		MATERIAL.BASIC_BLOCK:
			return "BLOCK"
		MATERIAL.ICE:
			return "ICE"
		MATERIAL.WOOD:
			return "WOOD"
		MATERIAL.GLASS:
			return "GLASS"
		_:
			return "???"

enum COLOR {
	NONE,
	RED,
	BLUE,
	GREEN,
	YELLOW,
	PURPLE,
	COLORLESS,
	PINK,
}
static func COLOR_NAME(col : COLOR) -> String:
	match col:
		COLOR.RED:
			return "RED"
		COLOR.BLUE:
			return "BLUE"
		COLOR.GREEN:
			return "GREEN"
		COLOR.YELLOW:
			return "YELLOW"
		COLOR.PURPLE:
			return "PURPLE"
		COLOR.PINK:
			return "PINK"
		COLOR.COLORLESS:
			return "COLORLESS"
		_:
			return "???"
static func get_color_texture(col : Icon.COLOR) -> Texture:
	match col:
		Icon.COLOR.RED:
			return preload("res://IconSprites/Red.png")
		Icon.COLOR.BLUE:
			return preload("res://IconSprites/Blue.png")
		Icon.COLOR.GREEN:
			return preload("res://IconSprites/Green.png")
		Icon.COLOR.YELLOW:
			return preload("res://IconSprites/Yellow.png")
		Icon.COLOR.PURPLE:
			return preload("res://IconSprites/Purple.png")
		Icon.COLOR.PINK:
			return preload("res://IconSprites/Pink.png")
		_:
			return null

@export var texture : Texture2D
@export var color : COLOR
@export var pop_type : POP_TYPE = POP_TYPE.GROUP
@export var material : MATERIAL = MATERIAL.BASIC_GEM
@export var rarity : int
@export var name : String
@export var description : String

@export var damage : int = 0
@export var block : int = 0
@export var gold : int = 0
@export var hurt : int = 0

func _init():
	pass

func pop(fight_controller, board):
	fight_controller.damage(damage, board.get_enemy())
	fight_controller.hurt(hurt, board.get_enemy())
	SaveManager.earn_gold(gold)
	fight_controller.block(block, board.get_enemy())

func icon_popped(fight_controller, board, popped_pos : Vector2i, this_board, this_pos : Vector2i):
	if material == MATERIAL.WOOD:
		if board == this_board and popped_pos.x == this_pos.x and popped_pos.y in [this_pos.y-1, this_pos.y+1]:
			board.destroy(this_pos)
		if board == this_board and popped_pos.y == this_pos.y and popped_pos.x in [this_pos.x-1, this_pos.x+1]:
			board.destroy(this_pos)

func move_used(fight_controller, board, this_pos : Vector2i):
	pass

# TODO: HIDDEN PROPERTY: ADD SPECIAL EXPORT WHEN MATERIAL IS ICE
var pops_after_x_moves : int = 3
func move_completed(fight_controller, board, this_pos : Vector2i):
	if material == MATERIAL.ICE:
		pops_after_x_moves -= 1
		if pops_after_x_moves <= 0:
			board.pop_piece(this_pos)
