extends Label

func _ready():
	text = str(get_parent().get_parent().moves) + " Moves"

func update_text(moves):
	text = str(moves) + " Moves"
