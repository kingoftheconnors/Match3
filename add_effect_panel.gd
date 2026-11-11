extends Panel

var effect : Icon.EFFECT

func set_effect(effect_val : Icon.EFFECT):
	effect = effect_val
	$MarginContainer/VBoxContainer/Name.text = Icon.EFFECT_NAME(effect)
	$MarginContainer/VBoxContainer/Control/TextureRect2.texture = Icon.get_effect_texture(effect)
	#$MarginContainer/VBoxContainer/Control/TextureRect.texture = Icon.get_color_foreground_texture(icon.color)
	$MarginContainer/VBoxContainer/Description.text = Icon.EFFECT_DESCRIPTION(effect)


func _on_pressed() -> void:
	emit_signal("effect_selected", effect)

signal effect_selected(effect : Icon.EFFECT)
