extends Panel

var relic : Relic

func set_relic(relic_val : Relic):
	relic = relic_val
	$MarginContainer/VBoxContainer/Name.text = relic.name
	#$MarginContainer/VBoxContainer/Control/TextureRect2.texture = Icon.get_color_texture(icon.color)
	#$MarginContainer/VBoxContainer/Control/TextureRect.texture = Icon.get_color_foreground_texture(icon.color)
	$MarginContainer/VBoxContainer/Description.text = relic.description


func _on_pressed() -> void:
	emit_signal("relic_selected", relic)

signal relic_selected(relic : Relic)
