extends ColorRect

@export var internet : NodePath

func refresh_internet():
	get_node(internet).refresh_internet()
	$Button/Refreshes/Label.text = str(get_node(internet).num_refreshes)

func _on_internet_set_enabled(flag):
	$Button.disabled = !flag
