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
	CharacterBody.set_motion_mode(CharacterBody.MOTION_MODE_GROUNDED)
	VelocityVector.target_position = CharacterBody.velocity / 10
	if JumpTimer.is_stopped():
		if CharacterBody.is_on_floor():
			if player_state != player_states.BREAKS:
				player_state = player_states.GROUNDED
		else:
			player_state = player_states.FLYING
	else:
		rotation_reset(delta)
		rotate_based_on_velocity(delta)
	if player_state == player_states.FLYING:
		get_directional_input()
		if input_dir:
			var input_rotated = input_dir.rotated(Vector3.UP, CharacterBody.get_node("Camera").rotation.y)
			var y_velocity_temp = CharacterBody.velocity.y
			CharacterBody.velocity.y = 0
			CharacterBody.velocity = CharacterBody.velocity.lerp(input_rotated * SPEED, TURNING_SPEED / 7 * delta)
			chosen_dir = chosen_dir.lerp(input_rotated, TURNING_SPEED / 7 * delta)
			CharacterBody.velocity.y = y_velocity_temp
		apply_gravity(delta)
		rotation_reset(delta)
		rotate_based_on_velocity(delta)
	elif player_state == player_states.GROUNDED:
		rotate_player_body(delta, 0, false)
		Center.force_raycast_update()
		rotate_player_body(delta, 1, true)
		Center.force_raycast_update()
		if not Center.is_colliding():
			player_state = player_states.FLOATING
			CharacterBody.velocity = CharacterBody.get_real_velocity()
		if player_state == player_states.FLOATING:
			CharacterBody.set_motion_mode(CharacterBody.MOTION_MODE_FLOATING)
			apply_gravity(delta)
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
	if player_state == player_states.JUMPING:
		CharacterBody.floor_snap_length = 0
	else:
		CharacterBody.floor_snap_length = 150
