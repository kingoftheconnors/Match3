extends Panel

var icon : Icon

func set_icon(icon_val : Icon):
	icon = icon_val
	$MarginContainer/VBoxContainer/Name.text = icon.name
	$MarginContainer/VBoxContainer/Control/TextureRect2.texture = Helpers.get_color_texture(icon.color)
	$MarginContainer/VBoxContainer/Control/TextureRect.texture = icon.texture
	$MarginContainer/VBoxContainer/Description.text = icon.description


func _on_pressed() -> void:
	emit_signal("icon_selected", icon)

signal icon_selected(icon : Icon)
