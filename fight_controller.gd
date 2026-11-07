extends Node2D
class_name level

@export var bag : Array[Icon]
var block_val : int = 0
var enemies : Array[Node2D] = []

func initialize(fight : Fight):
	bag = SaveManager.bag.duplicate()
	for e in fight.enemies:
		var board = preload("res://enemy_board.tscn").instantiate()
		board.position = Vector2(900, 360)
		var new_bag = bag.duplicate()
		new_bag.append_array(e.enemy_bag)
		board.set_size(enemies.size())
		board.set_board_size(Vector2i(6-fight.enemies.size(), 5))
		board.initialize(self, e, new_bag)
		add_child(board)
		enemies.push_back(board)

var total_gold_won : int = 0
func check_for_victory_or_defeat():
	for e in enemies:
		if e.get_health() <= 0:
			total_gold_won += e.get_gold()
			e.queue_free()
			enemies.erase(e)
			for ee in enemies:
				ee.set_board_size(Vector2i(6-enemies.size(), 5))
	if enemies.is_empty():
		var gold_collection_percentage = 0.2
		$VictoryWindow.show_victory_dialog(int(total_gold_won * gold_collection_percentage))
	if SaveManager.health <= 0:
		for e in enemies:
			e.process_mode = Node.PROCESS_MODE_DISABLED
		$DefeatWindow.visible = true

var is_move_processing : bool = false
func _process(_delta: float) -> void:
	match enemies.size():
		1:
			enemies[0].position.x = lerp(enemies[0].position.x, 850.0, 0.2)
			enemies[0].set_size(enemies[0].SIZE.LARGE)
		2:
			enemies[0].position.x = lerp(enemies[0].position.x, 340.0, 0.2)
			enemies[1].position.x = lerp(enemies[1].position.x, 970.0, 0.2)
			for e in enemies:
				e.set_size(e.SIZE.MEDIUM)
		3:
			enemies[0].position.x = lerp(enemies[0].position.x, 230.0, 0.2)
			enemies[1].position.x = lerp(enemies[1].position.x, 650.0, 0.2)
			enemies[2].position.x = lerp(enemies[2].position.x, 1075.0, 0.2)
			for e in enemies:
				e.set_size(e.SIZE.SMALL)
	# Mark move as complete
	for e in enemies:
		if e.is_settling():
			return
	if is_move_processing:
		is_move_processing = false
		_on_move_completed()

func remove_type(icon : Icon):
	if bag.has(icon):
		bag.erase(icon)

var game_lost : bool = false
func is_game_active():
	return game_lost == false

var combo_level : int = 0
func _on_combo_level_increased():
	combo_level += 1
func _on_combo_level_reset():
	if $Office.is_settling() == false:
		if combo_level != 0:
			combo_level = 0

func _on_move_used():
	for e in enemies:
		e.on_move_used()
func _on_move_completed() -> void:
	for e in enemies:
		e.on_move_completed()
func _on_icon_popped(icon: Icon, icon_pos: Vector2i, board) -> void:
	for e in enemies:
		e.on_icon_popped(icon, icon_pos, board)
func get_selected_piece():
	var selection : grid_piece = null
	for e in enemies:
		selection = e.get_selected_piece()
		if selection:
			break
	return selection

var selected_piece : grid_piece
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and visible and is_game_active():
			if selected_piece:
				reset_selected_piece()
			# Do not pickup pieces if board is still settling
			for e in enemies:
				if e.is_settling():
					return
			# Get clicked piece
			for e in enemies:
				selected_piece = e.get_piece_at_global_pos(event.position)
				if selected_piece:
					selected_piece.set_is_selected_piece(true)
					return
		else:
			if selected_piece:
				# Get dropped piece
				var dropped_piece : grid_piece = null
				for e in enemies:
					dropped_piece = e.get_piece_at_global_pos(event.position)
					if dropped_piece:
						break
				if dropped_piece:
					if dropped_piece.icon != selected_piece.icon:
						swap_pieces(dropped_piece, selected_piece)
						# Swap back if failed to make a match
						if (selected_piece.grid.get_group(selected_piece.grid.find_piece_position(selected_piece), []).size() < selected_piece.grid.get_required_group_size_for_type(selected_piece.icon) \
							and dropped_piece.grid.get_group(dropped_piece.grid.find_piece_position(dropped_piece), []).size() < dropped_piece.grid.get_required_group_size_for_type(dropped_piece.icon)):
							swap_pieces(dropped_piece, selected_piece)
						else:
							for e in enemies:
								e.pop_matches()
							is_move_processing = true
							_on_move_used()
						selected_piece.force_position_to(selected_piece.grid.find_piece_position(selected_piece), selected_piece.grid.get_piece_size())
						dropped_piece.force_position_to(dropped_piece.grid.find_piece_position(dropped_piece), dropped_piece.grid.get_piece_size())
			reset_selected_piece()
func swap_pieces(piece_1 : Node, piece_2 : Node):
	var piece_1_pos = piece_1.grid.find_piece_position(piece_1)
	var piece_2_pos = piece_2.grid.find_piece_position(piece_2)
	piece_1.grid.replace_piece(piece_1_pos, piece_2)
	piece_2.grid.replace_piece(piece_2_pos, piece_1)
	var piece_1_grid = piece_1.grid
	piece_1.grid = piece_2.grid
	piece_1.reparent(piece_1.grid)
	piece_2.grid = piece_1_grid
	piece_2.reparent(piece_2.grid)
func reset_selected_piece():
	if selected_piece:
		selected_piece.force_position_to(selected_piece.grid.find_piece_position(selected_piece), selected_piece.grid.get_piece_size())
		selected_piece.set_is_selected_piece(false)

func block(amo, _enemy):
	block_val += amo
	emit_signal("block_changed")
func get_block() -> int:
	return block_val
func enemy_block(amo, enemy):
	enemy.block(amo)
func damage(amo, enemy):
	enemy.hurt(amo)
	check_for_victory_or_defeat()
func hurt(amo, _enemy):
	if block_val >= amo:
		block_val -= amo
		emit_signal("block_changed")
	else:
		SaveManager.hurt(amo - block_val)
		block_val = 0
		emit_signal("block_changed")
	check_for_victory_or_defeat()

signal block_changed
