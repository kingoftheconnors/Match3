extends Node2D

@export var grid_piece : PackedScene

signal icon_popped(type : grid_piece.PIECE_TYPE, group_size : int)
signal move_used
signal set_enabled(flag : bool)
signal combo_level_increased
signal combo_level_reset

func add_piece_to_column(x, is_initial_setup : bool = false):
	var new_piece = grid_piece.instantiate()
	if loaded_pieces.size() > 0:
		var type = loaded_pieces.pop_at(randi()%loaded_pieces.size())
		new_piece.initialize(type, self, is_initial_setup)
	else:
		new_piece.initialize(get_piece_types()[randi()%get_piece_types().size()], self, is_initial_setup)
	new_piece.position = Vector2(x*piece_size.x+piece_size.x/2, (-board_size.y-2)*piece_size.y)
	board[x].append(new_piece)
	add_child(new_piece)

@export var board_size : Vector2i = Vector2i(6,6)

# Board is an array of board-columns
var board : Array[Array]

func _ready():
	scale.x = 5.25/board_size.x
	scale.y = 5.25/board_size.y
	
	for i in board_size.x:
		board.append([])
		for j in board_size.y:
			add_piece_to_column(i, true)
	var grid_has_matches : bool = true
	var resort_tries : int = 3
	while grid_has_matches and resort_tries > 0:
		grid_has_matches = false
		resort_tries -= 1
		for x in range(board_size.x):
			for y in range(board_size.y):
				var group = get_group(Vector2i(x,y), [])
				if group.size() >= 3:
					board[x][y].initialize(get_piece_types()[randi()%get_piece_types().size()], self, true)
					grid_has_matches = true

func reset():
	for x in range(board_size.x):
		for y in range(board_size.y):
			board[x][y].queue_free()
	board = []
	for i in board_size.x:
		board.append([])
		for j in board_size.y:
			add_piece_to_column(i)
	var grid_has_matches : bool = true
	var resort_tries : int = 3
	while grid_has_matches and resort_tries > 0:
		grid_has_matches = false
		resort_tries -= 1
		for x in range(board_size.x):
			for y in range(board_size.y):
				var group = get_group(Vector2i(x,y), [])
				if group.size() >= 3:
					board[x][y].initialize(get_piece_types()[randi()%get_piece_types().size()], self)
					grid_has_matches = true

func _process(delta):
	# Move all pieces down
	for x in range(board_size.x):
		for y in range(board_size.y):
			board[x][y].process_movement(delta, board[x][y-1] if y > 0 else null)
	# Make sure we're not falling
	for column in board:
		for piece in column:
			if piece.is_falling() and board[selected_piece.x][selected_piece.y] != piece:
				return
	# Pop all groups
	var is_combo_still_going = false
	for x in range(board_size.x):
		for y in range(board_size.y):
			if board[x][y].is_popped():
				continue
			var group = get_group(Vector2i(x,y), [])
			if group.size() >= get_required_group_size_for_type(board[x][y].type) and get_parent().is_game_active():
				for pos in group:
					pop_piece(pos, group.size())
					if selected_piece == pos:
						reset_selected_piece()
				is_combo_still_going = true
	# Update combo
	if is_combo_still_going:
		emit_signal("combo_level_increased")
	else:
		emit_signal("combo_level_reset")
	# Remove popped entries
	for column in board:
		for y in range(column.size()-1, -1, -1):
			if column[y].is_popped():
				var piece_to_delete = column[y]
				column.erase(piece_to_delete)
				piece_to_delete.queue_free()
				y -= 1
	# Add new entries
	for x in range(board_size.x):
		while board[x].size() < board_size.y:
			add_piece_to_column(x)

func has_poppable_groups() -> bool:
	for x in range(board_size.x):
		for y in range(board_size.y):
			var group = get_group(Vector2i(x,y), [])
			if group.size() >= get_required_group_size_for_type(board[x][y].type):
				return true
	return false

func find_piece_position(piece) -> Vector2i:
	for x in range(board_size.x):
		for y in range(board_size.y):
			if board[x][y] == piece:
				return Vector2i(x, y)
	return Vector2i(-1, -1)

func get_required_group_size_for_type(type : grid_piece.PIECE_TYPE) -> int:
	if type in get_parent().goals:
		return get_parent().goal_minimum_pop_size
	else:
		return 3

func get_group(pos : Vector2i, current_group : Array[Vector2i]) -> Array[Vector2i]:
	current_group.append(pos)
	var new_group : Array[Vector2i] = [pos]
	for check_pos in [pos+Vector2i.RIGHT,pos+Vector2i.LEFT,pos+Vector2i.UP,pos+Vector2i.DOWN]:
		if check_pos.x < 0 or check_pos.x >= board_size.x:
			continue
		if check_pos.y < 0 or check_pos.y >= board_size.y:
			continue
		if check_pos not in current_group and board[check_pos.x][check_pos.y].get_type() == board[pos.x][pos.y].get_type():
			for i in get_group(check_pos, current_group):
				current_group.append(i)
				new_group.append(i)
	return new_group

var piece_size = Vector2i(100, 100)
func get_piece_size() -> Vector2i:
	return piece_size
func get_speed_ratio():
	if get_parent().is_slow_generation:
		return 0.5
	else:
		return 1.0

var selected_piece : Vector2i = Vector2i(-1,-1)
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and visible and get_parent().is_game_active():
			var grid_pos = get_grid_position(to_local(event.position))
			if grid_pos.x < 0 or grid_pos.x >= board_size.x:
				return
			if grid_pos.y < 0 or grid_pos.y >= board_size.y:
				return
			if board[grid_pos.x][grid_pos.y].is_falling():
				return
			selected_piece = grid_pos
		else:
			if selected_piece.x >= 0 and selected_piece.y >= 0:
				var grid_pos = get_grid_position(to_local(event.position))
				if grid_pos.x >= 0 and grid_pos.x < board_size.x \
						and grid_pos.y >= 0 and grid_pos.y < board_size.y:
					if grid_pos != selected_piece and board[grid_pos.x][grid_pos.y].type != board[selected_piece.x][selected_piece.y].type:
						var swap_piece = board[grid_pos.x][grid_pos.y]
						board[grid_pos.x][grid_pos.y] = board[selected_piece.x][selected_piece.y]
						board[selected_piece.x][selected_piece.y] = swap_piece
						# Swap back if failed to make a match
						if (get_group(grid_pos, []).size() < get_required_group_size_for_type(board[grid_pos.x][grid_pos.y].type) \
							and get_group(selected_piece, []).size() < get_required_group_size_for_type(board[selected_piece.x][selected_piece.y].type)):
							swap_piece = board[grid_pos.x][grid_pos.y]
							board[grid_pos.x][grid_pos.y] = board[selected_piece.x][selected_piece.y]
							board[selected_piece.x][selected_piece.y] = swap_piece
						else:
							emit_signal("move_used")
						board[grid_pos.x][grid_pos.y].force_position_to(grid_pos, piece_size)
						board[selected_piece.x][selected_piece.y].force_position_to(selected_piece, piece_size)
				else:
					reset_selected_piece()
			var selected_pos = selected_piece
			selected_piece = Vector2i(-1,-1)
			board[selected_pos.x][selected_pos.y].process_movement(0.01, board[selected_pos.x][selected_pos.y-1] if selected_piece.y > 0 else null)

func set_grid_enabled(flag : bool):
	if flag:
		z_index = 1
	else:
		z_index = 0
	emit_signal("set_enabled", flag)

func is_settling():
	for column in board:
		for piece in column:
			if piece.is_falling() and board[selected_piece.x][selected_piece.y] != piece:
				return true
	return false

func pop_piece(pos : Vector2, group_size):
	if board[pos.x][pos.y].is_popped() == false:
		board[pos.x][pos.y].mark_popped()
		var type = board[pos.x][pos.y].type
		emit_signal("icon_popped", type, group_size)

func pop_all_of_type(type : grid_piece.PIECE_TYPE):
	for x in range(board_size.x):
		for y in range(board_size.y):
			if board[x][y].type == type:
				pop_piece(Vector2(x, y), 1)

func get_grid_position(position) -> Vector2i:
	if position.y > 0 or position.x < 0:
		return Vector2i(-1,-1)
	return Vector2i((position.x)/piece_size.x, (position.y)/-piece_size.y)
func is_selected_piece(piece) -> bool:
	if selected_piece.x >= 0 and selected_piece.y >= 0:
		if board[selected_piece.x][selected_piece.y] == piece:
			return true
	return false

var loaded_pieces : Array[grid_piece.PIECE_TYPE]
func load_piece(type : grid_piece.PIECE_TYPE):
	loaded_pieces.append(type)

func get_goals():
	return get_parent().goals
func get_obstacles():
	return get_parent().obstacles
func get_poppables():
	return get_parent().poppables
func get_extras():
	var extras = []
	for p in get_parent().piece_types + get_parent().internet_piece_types:
		if p in get_parent().goals:
			continue
		if p in get_parent().obstacles:
			continue
		if p in get_parent().poppables:
			continue
		extras.append(p)
	return extras
func get_piece_types():
	return get_parent().piece_types

func _on_level_flow_reset():
	reset_selected_piece()

func reset_selected_piece():
	if selected_piece.x >= 0 and selected_piece.y >= 0:
		board[selected_piece.x][selected_piece.y].force_position_to(selected_piece, piece_size)
		selected_piece = Vector2i(-1,-1)
