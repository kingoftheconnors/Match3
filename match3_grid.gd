extends Panel

signal icon_popped(type : Icon, group_size : int)
signal move_used
signal set_enabled(flag : bool)
signal combo_level_increased
signal combo_level_reset

func add_piece_to_column(x, is_initial_setup : bool = false):
	var new_piece = preload("res://grid_piece.tscn").instantiate()
	if queued_pieces.size() > 0:
		var type = queued_pieces.pop_at(randi()%queued_pieces.size())
		new_piece.initialize(type, self, is_initial_setup)
	else:
		new_piece.initialize(get_bag()[randi()%get_bag().size()], self, is_initial_setup)
	new_piece.position = Vector2(x*get_piece_size().x+get_piece_size().x/2, (-2)*get_piece_size().y)
	board[x].append(new_piece)
	add_child(new_piece)

@onready var fight_controller = get_parent()

@export var board_size : Vector2i = Vector2i(6,6)

# Board is an array of board-columns
var board : Array[Array]

func _ready():
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
					board[x][y].initialize(get_bag()[randi()%get_bag().size()], self, true)
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
					board[x][y].initialize(get_bag()[randi()%get_bag().size()], self)
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
			if group.size() >= get_required_group_size_for_type(board[x][y].icon) and get_parent().is_game_active():
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
			if group.size() >= get_required_group_size_for_type(board[x][y].icon):
				return true
	return false

func find_piece_position(piece) -> Vector2i:
	for x in range(board_size.x):
		for y in range(board_size.y):
			if board[x][y] == piece:
				return Vector2i(x, y)
	return Vector2i(-1, -1)

func get_required_group_size_for_type(_icon : Icon) -> int:
	return 3

func get_group(pos : Vector2i, current_group : Array[Vector2i], pop_type = null) -> Array[Vector2i]:
	if pop_type == Icon.POP_TYPE.GROUP or board[pos.x][pos.y].icon.pop_type == Icon.POP_TYPE.GROUP:
		current_group.append(pos)
		var new_group : Array[Vector2i] = [pos]
		for check_pos in [pos+Vector2i.RIGHT,pos+Vector2i.LEFT,pos+Vector2i.UP,pos+Vector2i.DOWN]:
			if check_pos.x < 0 or check_pos.x >= board_size.x:
				continue
			if check_pos.y < 0 or check_pos.y >= board_size.y:
				continue
			if check_pos not in current_group and board[check_pos.x][check_pos.y].get_color() == board[pos.x][pos.y].get_color():
				for i in get_group(check_pos, current_group):
					current_group.append(i)
					new_group.append(i)
		return new_group
	elif pop_type == Icon.POP_TYPE.LINE or board[pos.x][pos.y].icon.pop_type == Icon.POP_TYPE.LINE:
		current_group.append(pos)
		var horizontal_group : Array[Vector2i] = []
		if pos.x+1 < board_size.x and board[pos.x+1][pos.y].get_color() == board[pos.x][pos.y].get_color():
			horizontal_group.append(pos+Vector2i.RIGHT)
			if pos.x+2 < board_size.x and board[pos.x+2][pos.y].get_color() == board[pos.x][pos.y].get_color():
				horizontal_group.append(pos+Vector2i.RIGHT*2)
		if pos.x-1 >= 0 and board[pos.x-1][pos.y].get_color() == board[pos.x][pos.y].get_color():
			horizontal_group.append(pos+Vector2i.LEFT)
			if pos.x-2 >= 0 and board[pos.x-2][pos.y].get_color() == board[pos.x][pos.y].get_color():
				horizontal_group.append(pos+Vector2i.LEFT*2)
		
		var vertical_group : Array[Vector2i] = []
		if pos.y+1 < board_size.y and board[pos.x][pos.y+1].get_color() == board[pos.x][pos.y].get_color():
			vertical_group.append(pos+Vector2i.DOWN)
			if pos.y+2 < board_size.y and board[pos.x][pos.y+2].get_color() == board[pos.x][pos.y].get_color():
				vertical_group.append(pos+Vector2i.DOWN*2)
		if pos.y-1 >= 0 and board[pos.x][pos.y-1].get_color() == board[pos.x][pos.y].get_color():
			vertical_group.append(pos+Vector2i.UP)
			if pos.y-2 >= 0 and board[pos.x][pos.y-2].get_color() == board[pos.x][pos.y].get_color():
				vertical_group.append(pos+Vector2i.UP*2)
		
		var new_group : Array[Vector2i] = [pos]
		if horizontal_group.size() >= 2:
			new_group.append_array(horizontal_group)
		if vertical_group.size() >= 2:
			new_group.append_array(vertical_group)
		return new_group
	else:
		return []

func get_piece_size() -> Vector2i:
	return Vector2(size.x/board_size.x, size.y/board_size.y)
func get_speed_ratio():
	return 1.0

var selected_piece : Vector2i = Vector2i(-1,-1)
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and visible and get_parent().is_game_active():
			var grid_pos = get_grid_position(event.position)
			if grid_pos.x < 0 or grid_pos.x >= board_size.x:
				return
			if grid_pos.y < 0 or grid_pos.y >= board_size.y:
				return
			if board[grid_pos.x][grid_pos.y].is_falling():
				return
			selected_piece = grid_pos
		else:
			if selected_piece.x >= 0 and selected_piece.y >= 0:
				var grid_pos = get_grid_position(event.position)
				if grid_pos.x >= 0 and grid_pos.x < board_size.x \
						and grid_pos.y >= 0 and grid_pos.y < board_size.y:
					if grid_pos != selected_piece and board[grid_pos.x][grid_pos.y].icon != board[selected_piece.x][selected_piece.y].icon:
						var swap_piece = board[grid_pos.x][grid_pos.y]
						board[grid_pos.x][grid_pos.y] = board[selected_piece.x][selected_piece.y]
						board[selected_piece.x][selected_piece.y] = swap_piece
						# Swap back if failed to make a match
						if (get_group(grid_pos, []).size() < get_required_group_size_for_type(board[grid_pos.x][grid_pos.y].icon) \
							and get_group(selected_piece, []).size() < get_required_group_size_for_type(board[selected_piece.x][selected_piece.y].icon)):
							swap_piece = board[grid_pos.x][grid_pos.y]
							board[grid_pos.x][grid_pos.y] = board[selected_piece.x][selected_piece.y]
							board[selected_piece.x][selected_piece.y] = swap_piece
						else:
							emit_signal("move_used")
						board[grid_pos.x][grid_pos.y].force_position_to(grid_pos, get_piece_size())
						board[selected_piece.x][selected_piece.y].force_position_to(selected_piece, get_piece_size())
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
		board[pos.x][pos.y].icon.pop(fight_controller, self)
		board[pos.x][pos.y].mark_popped()
		emit_signal("icon_popped", board[pos.x][pos.y].icon, group_size)

func pop_all_of_type(icon : Icon):
	for x in range(board_size.x):
		for y in range(board_size.y):
			if board[x][y].icon == icon:
				pop_piece(Vector2(x, y), 1)

func get_grid_position(pos) -> Vector2i:
	if pos.y < 0 or pos.x < 0:
		return Vector2i(-1,-1)
	return Vector2i((pos.x)/get_piece_size().x, (pos.y-board_size.y*get_piece_size().y)/-get_piece_size().y)
func is_selected_piece(piece) -> bool:
	if selected_piece.x >= 0 and selected_piece.y >= 0:
		if board[selected_piece.x][selected_piece.y] == piece:
			return true
	return false

var queued_pieces : Array[Icon]
func load_piece(icon : Icon):
	queued_pieces.append(icon)

func get_bag():
	return get_parent().bag

func _on_level_flow_reset():
	reset_selected_piece()

func reset_selected_piece():
	if selected_piece.x >= 0 and selected_piece.y >= 0:
		board[selected_piece.x][selected_piece.y].force_position_to(selected_piece, get_piece_size())
		selected_piece = Vector2i(-1,-1)
