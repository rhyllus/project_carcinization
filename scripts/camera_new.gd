extends Node3D

var mouse_sensitivity := 0.001
var controller_sensitivity := 0.1
var twist_input := 0.0
var pitch_input := 0.0
var CharacterController

func _ready() -> void:
	CharacterController = get_parent()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sensitivity
			pitch_input = - event.relative.y * mouse_sensitivity

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	rotate_y(twist_input)
	$CameraPitch.rotate_x(pitch_input)
	if $CameraPitch.rotation.x < -PI/2:
		$CameraPitch.rotation.x = -PI/2
	elif $CameraPitch.rotation.x > PI/4:
		$CameraPitch.rotation.x = PI/4
	twist_input = 0
	pitch_input = 0
	CharacterController.check_camera_pos_validity(delta)
