extends Panel

var color : Icon.COLOR

func set_color(color_val : Icon.COLOR):
	color = color_val
	$MarginContainer/VBoxContainer/Name.text = Icon.COLOR_NAME(color)
	$MarginContainer/VBoxContainer/Control/TextureRect2.texture = Icon.get_color_texture(color)
	$MarginContainer/VBoxContainer/Control/TextureRect.texture = Icon.get_color_foreground_texture(color)
	$MarginContainer/VBoxContainer/Description.text = Icon.COLOR_DESCRIPTION(color)


func _on_pressed() -> void:
	emit_signal("color_selected", color)

signal color_selected(color : Icon.COLOR)
