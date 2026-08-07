extends Button

@export var level : PackedScene

func _ready():
	connect("pressed", goto_level)

func goto_level():
	get_tree().change_scene_to_packed(level)
