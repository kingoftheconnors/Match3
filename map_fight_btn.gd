extends Button

@export var fight : Fight

func _ready():
	text = fight.resource_name
	connect("pressed", start_fight)

func start_fight():
	var fight_obj = preload("res://fight.tscn").instantiate()
	fight_obj.initialize(fight)
	get_parent().add_child(fight_obj)
	disabled = true
