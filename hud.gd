extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SaveManager.connect("health_changed", update_hud)
	SaveManager.connect("gold_changed", update_hud)

func update_hud():
	$MarginContainer/HBoxContainer/Health.text = str(SaveManager.health) + "/" + str(SaveManager.max_health)
	$MarginContainer/HBoxContainer/Gold.text = str(SaveManager.gold)

func _exit_tree() -> void:
	SaveManager.disconnect("health_changed", update_hud)
	SaveManager.disconnect("gold_changed", update_hud)
