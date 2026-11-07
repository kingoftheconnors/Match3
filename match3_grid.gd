extends Panel

signal icon_popped(icon : Icon, icon_pos : Vector2i)
signal move_completed
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

var fight_controller : level

@export var board_size : Vector2i = Vector2i(6,6)
func set_board_size(new_size : Vector2i):
	if new_size.x < 1:
		new_size.x = 1
	if new_size.y < 1:
		new_size.y = 1
	if !is_node_ready():
		board_size = new_size
		return
	if new_size.y < board_size.y:
		for y in range(board_size.y-1, new_size.y-1, -1):
			for x in range(board_size.x):
				if piece_exists(Vector2i(x,y)):
					board[x][y].queue_free()
					board[x].pop_at(y)
	if board_size.x > new_size.x:
		for x in range(new_size.x, board_size.x):
			for i in board[x]:
				i.queue_free()
			board.pop_at(x)
	else:
		for x in range(new_size.x-board_size.x):
			board.append([])
	board_size = new_size

@export var enemy : NodePath
func get_enemy() -> Node2D:
	return get_node(enemy)

# Board is an array of board-columns
var board : Array[Array]
var bag : Array[Icon]

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
			for y in range(board[x].size()):
				var group = get_group(Vector2i(x,y), [])
				if group.size() >= 3:
					board[x][y].initialize(get_bag()[randi()%get_bag().size()], self, true)
					grid_has_matches = true

func reset():
	for x in range(board_size.x):
		for y in range(board[x].size()):
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
			for y in range(board[x].size()):
				var group = get_group(Vector2i(x,y), [])
				if group.size() >= 3:
					board[x][y].initialize(get_bag()[randi()%get_bag().size()], self)
					grid_has_matches = true

func _process(delta):
	# Move all pieces down
	for x in range(board_size.x):
		for y in range(board[x].size()):
			board[x][y].process_movement(delta, board[x][y-1] if y > 0 else null)
	# Make sure board isn't still settling
	for column in board:
		for piece in column:
			if piece.is_falling() and !piece.is_selected_piece:
				return
	# Pop all groups
	pop_matches()
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

func pop_matches():
	var is_combo_still_going = false
	for x in range(board_size.x):
		for y in range(board[x].size()):
			if board[x][y].is_popped():
				continue
			var group = get_group(Vector2i(x,y), [])
			if group.size() >= get_required_group_size_for_type(board[x][y].icon) and fight_controller.is_game_active():
				for pos in group:
					pop_piece(pos, group.size())
					if board[pos.x][pos.y].is_selected_piece:
						fight_controller.reset_selected_piece()
				is_combo_still_going = true
	# Update combo
	if is_combo_still_going:
		emit_signal("combo_level_increased")
	else:
		emit_signal("combo_level_reset")

func has_poppable_groups() -> bool:
	for x in range(board_size.x):
		for y in range(board[x].size()):
			var group = get_group(Vector2i(x,y), [])
			if group.size() >= get_required_group_size_for_type(board[x][y].icon):
				return true
	return false

func find_piece_position(piece) -> Vector2i:
	for x in range(board_size.x):
		for y in range(board[x].size()):
			if board[x][y] == piece:
				return Vector2i(x, y)
	return Vector2i(-1, -1)

func get_required_group_size_for_type(_icon : Icon) -> int:
	return 3
func piece_exists(pos : Vector2i):
	return board.size() > pos.x and board[pos.x].size() > pos.y

func get_group(pos : Vector2i, current_group : Array, pop_type = null) -> Array[Vector2i]:
	if board[pos.x][pos.y].get_color() == Icon.COLOR.COLORLESS:
		return []
	if pop_type == Icon.POP_TYPE.GROUP or board[pos.x][pos.y].icon.pop_type == Icon.POP_TYPE.GROUP:
		current_group.append(pos)
		var new_group : Array[Vector2i] = [pos]
		for check_pos in [pos+Vector2i.RIGHT,pos+Vector2i.LEFT,pos+Vector2i.UP,pos+Vector2i.DOWN]:
			if check_pos.x < 0 or check_pos.x >= board_size.x:
				continue
			if check_pos.y < 0 or check_pos.y >= board_size.y:
				continue
			if check_pos not in current_group and piece_exists(check_pos) and board[check_pos.x][check_pos.y].get_color() == board[pos.x][pos.y].get_color():
				for i in get_group(check_pos, current_group):
					current_group.append(i)
					new_group.append(i)
		return new_group
	elif pop_type == Icon.POP_TYPE.LINE or board[pos.x][pos.y].icon.pop_type == Icon.POP_TYPE.LINE:
		current_group.append(pos)
		var horizontal_group : Array[Vector2i] = []
		if pos.x+1 < board_size.x and piece_exists(pos+Vector2i.RIGHT) and board[pos.x+1][pos.y].get_color() == board[pos.x][pos.y].get_color():
			horizontal_group.append(pos+Vector2i.RIGHT)
			if pos.x+2 < board_size.x and piece_exists(pos+Vector2i.RIGHT*2) and  board[pos.x+2][pos.y].get_color() == board[pos.x][pos.y].get_color():
				horizontal_group.append(pos+Vector2i.RIGHT*2)
		if pos.x-1 >= 0 and piece_exists(pos+Vector2i.LEFT) and board[pos.x-1][pos.y].get_color() == board[pos.x][pos.y].get_color():
			horizontal_group.append(pos+Vector2i.LEFT)
			if pos.x-2 >= 0 and piece_exists(pos+Vector2i.LEFT*2) and board[pos.x-2][pos.y].get_color() == board[pos.x][pos.y].get_color():
				horizontal_group.append(pos+Vector2i.LEFT*2)
		
		var vertical_group : Array[Vector2i] = []
		if pos.y+1 < board[pos.x].size() and piece_exists(pos+Vector2i.DOWN) and board[pos.x][pos.y+1].get_color() == board[pos.x][pos.y].get_color():
			vertical_group.append(pos+Vector2i.DOWN)
			if pos.y+2 < board_size.y and piece_exists(pos+Vector2i.DOWN*2) and board[pos.x][pos.y+2].get_color() == board[pos.x][pos.y].get_color():
				vertical_group.append(pos+Vector2i.DOWN*2)
		if pos.y-1 >= 0 and piece_exists(pos+Vector2i.UP*1) and board[pos.x][pos.y-1].get_color() == board[pos.x][pos.y].get_color():
			vertical_group.append(pos+Vector2i.UP)
			if pos.y-2 >= 0 and piece_exists(pos+Vector2i.UP*2) and board[pos.x][pos.y-2].get_color() == board[pos.x][pos.y].get_color():
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

func replace_piece(pos, piece):
	board[pos.x][pos.y] = piece

func set_grid_enabled(flag : bool):
	if flag:
		z_index = 1
	else:
		z_index = 0
	emit_signal("set_enabled", flag)

func is_settling():
	for column in board:
		for piece in column:
			if (piece.is_falling() or piece.is_popped()) and !piece.is_selected_piece:
				return true
	return false

func pop_piece(pos : Vector2, _group_size = 1):
	if board[pos.x][pos.y].is_popped() == false:
		board[pos.x][pos.y].icon.pop(fight_controller, self)
		board[pos.x][pos.y].mark_popped()
		emit_signal("icon_popped", board[pos.x][pos.y].icon, pos, self)

func destroy(pos : Vector2i):
	if board[pos.x][pos.y].is_popped() == false:
		board[pos.x][pos.y].mark_popped()

func get_board_size() -> Vector2i:
	return board_size
func get_grid_position(pos) -> Vector2i:
	if pos.y < 0 or pos.x < 0:
		return Vector2i(-1,-1)
	return Vector2i((pos.x)/get_piece_size().x, (pos.y-board_size.y*get_piece_size().y)/-get_piece_size().y)
func get_piece_at_global_pos(pos) -> grid_piece:
	var grid_pos = get_grid_position(pos-global_position)
	if grid_pos.x < 0 or grid_pos.x >= board_size.x:
		return null
	if grid_pos.y < 0 or grid_pos.y >= board_size.y:
		return null
	if board[grid_pos.x][grid_pos.y].is_falling():
		return null
	return board[grid_pos.x][grid_pos.y]

var queued_pieces : Array[Icon]
func load_piece(icon : Icon):
	queued_pieces.append(icon)

func get_bag():
	return bag

func get_amount_of_material(mat : Icon.MATERIAL) -> int:
	var damage = 0
	for column in board:
		for piece in column:
			if piece.is_on_board() and piece.is_popped() == false \
				and piece.icon.material == mat:
				damage += 1
	return damage

func transmute_random(amount : int, from_color : Icon.COLOR, from_material : Icon.MATERIAL, to_color : Icon.COLOR, to_material : Icon.MATERIAL):
	var icons_to_transmute : Array
	for column in board:
		for piece in column:
			if piece.is_on_board() and piece.is_popped() == false \
				and (from_color == Icon.COLOR.NONE or piece.icon.color == from_color) \
				and (from_material == Icon.MATERIAL.NONE or piece.icon.material == from_material):
				icons_to_transmute.append(piece)
	if amount < icons_to_transmute.size():
		for i in amount:
			icons_to_transmute[randi()%icons_to_transmute.size()].transmute(to_color, to_material)
	else:
		for i in icons_to_transmute:
			i.transmute(to_color, to_material)

func on_move_used() -> void:
	for x in range(board_size.x):
		for y in range(board[x].size()):
			if board[x][y].is_popped():
				continue
			board[x][y].move_used(fight_controller, self, Vector2i(x,y))
func on_move_completed() -> void:
	for x in range(board_size.x):
		for y in range(board[x].size()):
			if board[x][y].is_popped():
				continue
			board[x][y].move_completed(fight_controller, self, Vector2i(x,y))

func on_icon_popped(_icon: Icon, icon_pos: Vector2i, icon_board) -> void:
	for x in range(board_size.x):
		for y in range(board[x].size()):
			if board[x][y].is_popped():
				continue
			board[x][y].icon_popped(fight_controller, icon_board, icon_pos, Vector2i(x,y))
