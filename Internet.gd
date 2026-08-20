extends "../Match3Grid.gd"

func refresh_internet():
	if visible:
		if get_parent().num_refreshes > 0:
			reset()
		get_parent().num_refreshes -= 1

func get_piece_types():
	return get_parent().internet_piece_types

func get_speed_ratio():
	if get_parent().is_slow_generation:
		return 0.3
	else:
		return 0.7
