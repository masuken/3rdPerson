extends Node3D

var sens = .1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	top_level
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _unhandled_input(event: InputEvent) -> void:
	
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	if event is InputEventMouseMotion:
		rotation_degrees.x -= event.relative.y * sens
		rotation_degrees.x = clamp(rotation_degrees.x, -90, 30)
		
		rotation_degrees.y -= event.relative.x * sens
		rotation_degrees.y = wrapf(rotation_degrees.y, 0, 360)
		
	
	

