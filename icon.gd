class_name Icon
extends Resource

enum MATERIAL {
	NONE,
	GEM, # Line of 3
	METAL, # Group of 4
	GLASS, # Falls 2 blocks
	ANVIL, #(metal that is heavy),
	#BALLOON,
	#SHADOW (can pop with same color OR other shadows, gets destroyed by light)
	#SPIRIT (double effect, but fades after one round),
}
static func MATERIAL_NAME(mat : MATERIAL) -> String:
	match mat:
		MATERIAL.GEM:
			return "GEM"
		MATERIAL.METAL:
			return "METAL"
		_:
			return "???"

enum EFFECT {
	NONE,
	BOMB,
	SPRAYPAINT, # Mutates unpopped neighbors into same color
	CHISEL, # Destroys random enemy node or ice
	#GUNPOWDER (cannot match, explodes when set on fire)
	#CLOCK,
	#LIGHTBULB, #(colorless, gems in 3x3 area are double powered)
	#SPOTLIGHT, #(colorless, gems in row are double powered)
	#GENERATOR, #(+X damage to all metal in group when popped)
	#MOLOTOV, #Sets all adjacent icons on fire
	#CASE (becomes random good icon when shattered)
	#COIN (can be flipped during a combo to extend a combo),
	#BAG (turns whatever color effect this is to "steal")
}
static func EFFECT_NAME(eff : EFFECT) -> String:
	match eff:
		EFFECT.BOMB:
			return "Bomb"
		EFFECT.SPRAYPAINT:
			return "Spraypaint"
		EFFECT.CHISEL:
			return "Chisel"
		_:
			return "???"
static func EFFECT_DESCRIPTION(eff : EFFECT) -> String:
	match eff:
		EFFECT.BOMB:
			return "Destroys all neighboring icons"
		EFFECT.SPRAYPAINT:
			return "Mutates all neighboring icons to this icon's color"
		EFFECT.CHISEL:
			return "Mutates one enemy-icon into this icon's color"
		_:
			return "???"
static func get_effect_texture(eff : Icon.EFFECT) -> Texture:
	match eff:
		Icon.EFFECT.BOMB:
			return preload("res://IconSprites/Bomb.png")
		Icon.EFFECT.SPRAYPAINT:
			return preload("res://IconSprites/Spraypaint.png")
		Icon.EFFECT.CHISEL:
			return preload("res://IconSprites/Chisel.png")
		_:
			return null

enum COLOR {
	NONE,
	RED,
	BLUE,
	GREEN,
	YELLOW,
	PURPLE,
	COLORLESS,
	PINK,
	ICE,
	WOOD,
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
		COLOR.WOOD:
			return "WOOD"
		COLOR.ICE:
			return "ICE"
		_:
			return "???"
static func COLOR_DESCRIPTION(col : COLOR) -> String:
	match col:
		COLOR.RED:
			return "Deal one damage"
		COLOR.BLUE:
			return "Add one block"
		COLOR.GREEN:
			return "Deal three damage"
		COLOR.YELLOW:
			return "Earn one gold"
		COLOR.PURPLE:
			return "Take one damage"
		COLOR.PINK:
			return "Take three damage"
		COLOR.COLORLESS:
			return "Unpoppable"
		COLOR.WOOD:
			return "Does nothing. Pops when nearby icons are popped."
		COLOR.ICE:
			return "Does nothing. Pops after being on the board for three moves."
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
		COLOR.ICE:
			return preload("res://IconSprites/Ice.png")
		COLOR.WOOD:
			return preload("res://IconSprites/Wood.png")
		_:
			return null
static func get_color_foreground_texture(col : Icon.COLOR):
	match col:
		Icon.COLOR.RED:
			return preload("res://IconSprites/BasicAttack.png")
		Icon.COLOR.BLUE:
			return preload("res://IconSprites/BasicDefend.png")
		Icon.COLOR.GREEN:
			return preload("res://IconSprites/BasicSuper.png")
		Icon.COLOR.YELLOW:
			return preload("res://IconSprites/BasicMoney.png")
		Icon.COLOR.PURPLE:
			return preload("res://IconSprites/BasicEnemyAttack.png")
		Icon.COLOR.PINK:
			return preload("res://IconSprites/BasicEnemySuper.png")
		_:
			return null
static func is_matchable_color(col : Icon.COLOR) -> bool:
	match col:
		Icon.COLOR.COLORLESS:
			return false
		Icon.COLOR.ICE:
			return false
		Icon.COLOR.WOOD:
			return false
		_:
			return true

static func get_material_texture(mat : Icon.MATERIAL) -> Texture:
	match mat:
		_:
			return null

@export var color : COLOR
@export var rarity : int
@export var name : String
@export var description : String
@export var material : MATERIAL = MATERIAL.GEM
@export var effect : EFFECT = EFFECT.NONE

@export var damage : int = 0
@export var block : int = 0
@export var gold : int = 0
@export var hurt : int = 0

func _init():
	pass

func pop(fight_controller, board, position : Vector2i):
	match color:
		Icon.COLOR.RED:
			var amount = 1
			if SaveManager.has_relic_classification("GOLD_DAMAGE"):
				amount += int(SaveManager.gold/20)
			fight_controller.damage(amount, board.get_enemy())
		Icon.COLOR.BLUE:
			fight_controller.block(1, board.get_enemy())
		Icon.COLOR.GREEN:
			fight_controller.damage(3, board.get_enemy())
		Icon.COLOR.YELLOW:
			SaveManager.earn_gold(1)
		Icon.COLOR.PURPLE:
			# Check if fight is over. If it is, don't risk killing player
			if fight_controller.is_all_enemies_defeated() == false:
				fight_controller.hurt(1, board.get_enemy())
		Icon.COLOR.PINK:
			# Check if fight is over. If it is, don't risk killing player
			if fight_controller.is_all_enemies_defeated() == false:
				fight_controller.hurt(3, board.get_enemy())
		Icon.COLOR.ICE:
			if SaveManager.has_relic_classification("ICE_SHIELD"):
				fight_controller.block(3, board.get_enemy())
		Icon.COLOR.WOOD:
			if SaveManager.has_relic_classification("WOOD_DAMAGE"):
				fight_controller.damage(1, board.get_enemy())
		_:
			return null
	match effect:
		Icon.EFFECT.BOMB:
			var method = "pop_piece" if SaveManager.has_relic_classification("BOMB_CHAIN_REACTION") else "destroy"
			board.call_deferred(method, position+Vector2i.LEFT)
			board.call_deferred(method, position+Vector2i.RIGHT)
			board.call_deferred(method, position+Vector2i.UP)
			board.call_deferred(method, position+Vector2i.DOWN)
			if SaveManager.has_relic_classification("BIG_EXPLOSIONS"):
				board.call_deferred(method, position+Vector2i.LEFT+Vector2i.UP)
				board.call_deferred(method, position+Vector2i.RIGHT+Vector2i.UP)
				board.call_deferred(method, position+Vector2i.LEFT+Vector2i.DOWN)
				board.call_deferred(method, position+Vector2i.RIGHT+Vector2i.DOWN)
		Icon.EFFECT.SPRAYPAINT:
			board.call_deferred("transmute_position", position+Vector2i.LEFT, color, MATERIAL.NONE)
			board.call_deferred("transmute_position", position+Vector2i.RIGHT, color, MATERIAL.NONE)
			board.call_deferred("transmute_position", position+Vector2i.UP, color, MATERIAL.NONE)
			board.call_deferred("transmute_position", position+Vector2i.DOWN, color, MATERIAL.NONE)
		Icon.EFFECT.CHISEL:
			var blocks_to_break = 1
			if SaveManager.has_relic_classification("DOUBLE_CHISEL"):
				blocks_to_break *= 2
			for i in range(blocks_to_break):
				var amount_changed = board.transmute_random(1, COLOR.PURPLE, MATERIAL.NONE, color, MATERIAL.NONE)
				if (amount_changed == 0):
					board.transmute_random(1, COLOR.ICE, MATERIAL.NONE, color, MATERIAL.NONE)

func icon_popped(fight_controller, board, popped_pos : Vector2i, this_board, this_pos : Vector2i):
	if color == COLOR.WOOD:
		if board == this_board and popped_pos.x == this_pos.x and popped_pos.y in [this_pos.y-1, this_pos.y+1]:
			board.destroy(this_pos)
		if board == this_board and popped_pos.y == this_pos.y and popped_pos.x in [this_pos.x-1, this_pos.x+1]:
			board.destroy(this_pos)

func move_used(fight_controller, board, this_pos : Vector2i):
	pass

# TODO: HIDDEN PROPERTY: ADD SPECIAL EXPORT WHEN MATERIAL IS ICE
var pops_after_x_moves : int = 3
func move_completed(fight_controller, board, this_pos : Vector2i):
	if color == COLOR.ICE:
		pops_after_x_moves -= 1
		if SaveManager.has_relic_classification("FAST_ICE"):
			pops_after_x_moves -= 1
		if pops_after_x_moves <= 0:
			board.pop_piece(this_pos)
