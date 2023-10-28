@icon("res://icons/sonic_like.png")
extends PlayerProperties
class_name SonicLike

func _ready():
	change_gravity(Vector3.UP)
	
	if get_child_count() != 0:
		for i in get_children():
			if i is MeshInstance3D and i.name == "SceneGraphic":
				i.queue_free()
			elif i != CharacterBody:
				i.reparent(CharacterBody, false)
	
	CharacterBody.floor_snap_length = 150
	CharacterBody.floor_stop_on_slope = true
	CharacterBody.slide_on_ceiling = true
	CharacterBody.floor_constant_speed = true
	CharacterBody.floor_max_angle = 88.9 * (PI/180)

func _physics_process(delta):
	HorizontalMidair.global_position = CharacterBody.global_position
	CharacterBody.set_motion_mode(CharacterBody.MOTION_MODE_GROUNDED)
	VelocityVector.target_position = CharacterBody.velocity / 10
	if CharacterBody.is_on_floor():
		if player_state != player_states.BREAKS:
			player_state = player_states.GROUNDED
	else:
		player_state = player_states.FLYING
	if player_state == player_states.FLYING:
		apply_gravity(delta)
		rotation_reset(delta)
	elif player_state == player_states.GROUNDED:
		rotate_player_body(delta, 0, false)
		rotate_player_body(delta, 1, true)
		if player_state == player_states.FLOATING:
			CharacterBody.set_motion_mode(CharacterBody.MOTION_MODE_FLOATING)
		else:
			get_directional_input()
			horizontal_movement(delta)
			if player_state == player_states.BREAKS:
				breaks(delta)
			else:
				CharacterBody.apply_floor_snap()
				CharacterBody.velocity = horizontal_velocity
		if CharacterBody.get_real_velocity() != Vector3.ZERO:
			rotate_based_on_velocity(delta)
	elif player_state == player_states.BREAKS:
		rotate_player_body(delta, 0, false)
		rotate_player_body(delta, 1, true)
		breaks(delta)
	jump_input(delta)
	CharacterBody.move_and_slide()
