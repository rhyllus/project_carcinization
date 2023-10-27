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
	VelocityVector.target_position = CharacterBody.velocity / 10
	if player_state == player_states.FLYING:
		apply_gravity(delta)
	elif player_state == player_states.GROUNDED:
		get_directional_input()
		horizontal_movement(delta)
		CharacterBody.velocity = horizontal_velocity
	if CharacterBody.is_on_floor():
		player_state = player_states.GROUNDED
	else:
		player_state = player_states.FLYING
	CharacterBody.move_and_slide()
