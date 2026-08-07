extends "../Match3Grid.gd"

@export var piece_types : Array[grid_piece.PIECE_TYPE]
@export var num_refreshes : int = 3

func refresh_internet():
	if visible:
		if num_refreshes > 0:
			reset()
		num_refreshes -= 1

func get_piece_types():
	return piece_types
