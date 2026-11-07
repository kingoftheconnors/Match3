class_name DestroyEffect
extends EnemyEffect

enum SECTION_TYPE {
	ROW,
	COLUMN,
	BOX,
}

enum SELECTION_TYPE {
	RANDOM,
	#MOST_PLAYER_ICONS,
	#SPECIFIC_MATERIAL,
	#SPECIFIC_COLOR
}
@export var section_type : SECTION_TYPE
@export var selection_type : SELECTION_TYPE
@export var material : Icon.MATERIAL
@export var color : Icon.COLOR

func do_effect(fight_controller, board) -> bool:
	var completed_effect = super(fight_controller, board)
	if completed_effect:
		return true
	if moves_left <= 0:
		if section_type == SECTION_TYPE.ROW:
			var row = randi()%board.get_board_size().y
			for x in range(board.get_board_size().x):
				board.destroy(Vector2i(x, row))
		elif section_type == SECTION_TYPE.COLUMN:
			var column = randi()%board.get_board_size().x
			for y in range(board.get_board_size().y):
				board.destroy(Vector2i(column, y))
		elif section_type == SECTION_TYPE.BOX:
			var row = randi()%(board.get_board_size().y-2)
			var column = randi()%(board.get_board_size().x-2)
			for x in range(column, column+3):
				for y in range(row, row+3):
					board.destroy(Vector2i(x, y))
		return true
	return false

func get_current_effect_glyphs(_fight_controller, _board) -> Array[TextureRect]:
	var ret : Array[TextureRect] = []
	# Attack glyph
	if section_type == SECTION_TYPE.ROW:
		var intent = create_intent_node(preload("res://IntentGlyphs/DestroyRow.png"))
		intent.tooltip_text = "Destroys a row of icons"
		ret.append(intent)
	elif section_type == SECTION_TYPE.COLUMN:
		var intent = create_intent_node(preload("res://IntentGlyphs/DestroyColumn.png"))
		intent.tooltip_text = "Destroys a column of icons"
		ret.append(intent)
	elif section_type == SECTION_TYPE.BOX:
		var intent = create_intent_node(preload("res://IntentGlyphs/DestroyArea.png"))
		intent.tooltip_text = "Destroys a 3x3 box of icons"
		ret.append(intent)
	return ret
