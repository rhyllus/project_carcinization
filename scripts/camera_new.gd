extends Node3D

var mouse_sensitivity := 0.001
var controller_sensitivity := 0.1
var twist_input := 0.0
var pitch_input := 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sensitivity
			pitch_input = - event.relative.y * mouse_sensitivity

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$CameraPitch.rotation.x = clamp($CameraPitch.rotation.x, -PI/2, PI/2)
	rotate_y(twist_input)
	$CameraPitch.rotate_x(pitch_input)
	twist_input = 0
	pitch_input = 0
