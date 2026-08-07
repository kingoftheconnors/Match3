extends "../grid_piece.gd"

func initialize(piece_type : PIECE_TYPE, grid_obj):
	super(piece_type, grid_obj)
	modulate = Color.GRAY
	if (piece_type in grid_obj.get_goals()):
		modulate = level.PROGRESS_COLOR
	if (piece_type in grid_obj.get_obstacles()):
		modulate = level.OBSTACLE_COLOR
	if (piece_type in grid_obj.get_poppables()):
		var index = grid_obj.get_poppables().find(piece_type)
		modulate = level.POPPABLES_COLORS[index]
	match piece_type:
		PIECE_TYPE.AD:
			texture = preload("res://OfficeIcons/adware.png")
			#modulate = Color.YELLOW
		PIECE_TYPE.AD2:
			texture = preload("res://OfficeIcons/marketing.png")
			#modulate = Color.YELLOW
		PIECE_TYPE.NEWSLETTER:
			texture = preload("res://OfficeIcons/check-list.png")
			#modulate = Color.YELLOW
		PIECE_TYPE.PHISHING:
			texture = preload("res://OfficeIcons/scam.png")
			#modulate = Color.YELLOW
		PIECE_TYPE.VIRUS:
			texture = preload("res://OfficeIcons/strategy.png")
			#modulate = Color.RED
		PIECE_TYPE.DATA:
			texture = preload("res://OfficeIcons/study.png")
			#modulate = Color.AQUA
		PIECE_TYPE.CONTACT:
			texture = preload("res://OfficeIcons/strategic.png")
		PIECE_TYPE.SUPPORT_TICKET:
			texture = preload("res://OfficeIcons/puzzle.png")
		PIECE_TYPE.APPLICANT:
			texture = preload("res://OfficeIcons/job-interview.png")
		_:
			modulate = Color.TRANSPARENT
