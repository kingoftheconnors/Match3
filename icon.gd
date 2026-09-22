class_name Icon
extends Resource

enum POP_TYPE {
	GROUP,
	LINE,
}

enum COLOR {
	RED,
	BLUE,
	GREEN,
	YELLOW,
	PURPLE,
}

@export var texture : Texture2D
@export var color : COLOR
@export var pop_type : POP_TYPE = POP_TYPE.GROUP

@export var damage : int = 0
@export var block : int = 0
@export var gold : int = 0
@export var hurt : int = 0

func _init():
	pass

func pop(fight_controller, board):
	fight_controller.damage(damage)
	fight_controller.hurt(hurt)
	SaveManager.earn_gold(gold)
	fight_controller.block(block)
