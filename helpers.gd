extends Node

# Called when the node enters the scene tree for the first time.
func get_color_texture(color : Icon.COLOR) -> Texture:
	match color:
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
		_:
			return null
