extends Button

var plugged_in : bool

@export var main : NodePath
@export var internet : NodePath

func _on_mouse_entered():
	$Wire1/Outline.visible=true
func _on_mouse_exited():
	$Wire1/Outline.visible=false

func _on_pressed():
	if $AnimationPlayer.is_playing():
		return
	if plugged_in:
		$AnimationPlayer.play("plug_out")
		get_node(main).enable()
		get_node(internet).disable()
		plugged_in = false
	else:
		$AnimationPlayer.play("plug_in")
		await $AnimationPlayer.animation_finished
		get_node(main).disable()
		get_node(internet).enable()
		plugged_in = true
