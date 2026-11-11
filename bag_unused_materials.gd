extends VBoxContainer

@export var bag_pieces : NodePath

func open():
	for i in get_children():
		i.queue_free()
	for mat in SaveManager.unused_upgrade_materials:
		var new_piece = preload("res://bag_addable_color.tscn").instantiate()
		new_piece.connect("material_applied_to_bag", material_applied_to_bag)
		new_piece.material = mat
		add_child(new_piece)
	for col in SaveManager.unused_upgrade_colors:
		var new_piece = preload("res://bag_addable_color.tscn").instantiate()
		new_piece.connect("color_applied_to_bag", color_applied_to_bag)
		new_piece.color = col
		new_piece.texture = Icon.get_color_texture(col)
		new_piece.bag_pieces = get_node(bag_pieces)
		add_child(new_piece)
	for eff in SaveManager.unused_upgrade_effects:
		var new_piece = preload("res://bag_addable_effect.tscn").instantiate()
		new_piece.connect("effect_applied_to_bag", effect_applied_to_bag)
		new_piece.effect = eff
		new_piece.texture = Icon.get_effect_texture(eff)
		new_piece.bag_pieces = get_node(bag_pieces)
		add_child(new_piece)

func material_applied_to_bag(mat : Icon.MATERIAL):
	SaveManager.unused_upgrade_materials.erase(mat)
	open()
func color_applied_to_bag(color : Icon.COLOR):
	SaveManager.unused_upgrade_colors.erase(color)
	open()
func effect_applied_to_bag(effect : Icon.EFFECT):
	SaveManager.unused_upgrade_effects.erase(effect)
	open()
