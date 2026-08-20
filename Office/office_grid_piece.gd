extends "../grid_piece.gd"

func initialize(piece_type : PIECE_TYPE, grid_obj, is_initial_setup : bool = false):
	super(piece_type, grid_obj, is_initial_setup)
	modulate = Color.GRAY
	if (piece_type in grid_obj.get_goals()):
		var index = grid_obj.get_goals().find(piece_type)
		modulate = level.PROGRESS_COLORS[index]
	elif (piece_type in grid_obj.get_obstacles()):
		modulate = level.OBSTACLE_COLOR
	elif (piece_type in grid_obj.get_poppables()):
		var index = grid_obj.get_poppables().find(piece_type)
		modulate = level.POPPABLES_COLORS[index]
	else:
		var index = grid_obj.get_extras().find(piece_type)
		modulate = level.EXTRAS_COLORS[index]
	match piece_type:
		PIECE_TYPE.ANALYTICS:
			texture = preload("res://Office/analytics.png")
		PIECE_TYPE.AD:
			texture = preload("res://Office/adware.png")
			#modulate = Color.YELLOW
		PIECE_TYPE.AD2:
			texture = preload("res://Office/marketing.png")
			#modulate = Color.YELLOW
		PIECE_TYPE.BILL:
			texture = preload("res://Office/bill.png")
		PIECE_TYPE.NEWSLETTER:
			texture = preload("res://Office/check-list.png")
			#modulate = Color.YELLOW
		PIECE_TYPE.PHISHING:
			texture = preload("res://Office/scam.png")
			#modulate = Color.YELLOW
		PIECE_TYPE.VIRUS:
			texture = preload("res://Office/strategy.png")
			#modulate = Color.RED
		PIECE_TYPE.BUG:
			texture = preload("res://Office/bug.png")
		PIECE_TYPE.BACTERIA:
			texture = preload("res://Office/bacteria.png")
		PIECE_TYPE.EMAIL:
			texture = preload("res://Office/email.png")
		PIECE_TYPE.HOUSE:
			texture = preload("res://Office/house-cleaning.png")
		PIECE_TYPE.HTML:
			texture = preload("res://Office/html.png")
		PIECE_TYPE.DATA:
			texture = preload("res://Office/study.png")
			#modulate = Color.AQUA
		PIECE_TYPE.CONTACT:
			texture = preload("res://Office/strategic.png")
		PIECE_TYPE.SUPPORT_TICKET:
			texture = preload("res://Office/puzzle.png")
		PIECE_TYPE.APPLICANT:
			texture = preload("res://Office/job-interview.png")
		_:
			modulate = Color.TRANSPARENT
