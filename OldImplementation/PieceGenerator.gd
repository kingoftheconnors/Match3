extends Node2D

@export var piece_container : NodePath

func _ready():
	generate_piece()

func generate_piece():
	var piece = preload("res://OldImplementation/piece.tscn").instantiate()
	piece.position = self.position - get_node(piece_container).position
	piece.piece_type = get_parent().get_random_piece_type()
	get_node(piece_container).add_child(piece)

func _on_body_exited(body):
	call_deferred("generate_piece")
