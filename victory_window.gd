extends CanvasLayer

func show_victory_dialog(gold):
	visible = true
	if gold > 0:
		$VBoxContainer/Panel/MarginContainer/VBoxContainer/GetGold.set_gold(gold)
