extends Control

@export var internet : NodePath

func _ready():
	if get_parent().is_internet_active == false:
		visible = false

func refresh_internet():
	get_node(internet).refresh_internet()
	$Button/Refreshes/Label.text = str(get_parent().num_refreshes)

func _on_internet_set_enabled(flag):
	$Button.disabled = !flag
