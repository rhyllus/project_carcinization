extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var ground = []

var input_dir : Vector2
var direction : Vector3
var chosen_direction : Vector3 = Vector3.ZERO
var direction_rotated : Vector3
var hit_the_breaks : bool = false
const turning_speed := 4.6
var speed_loss_vector : Vector3

@onready var Front = $VectorTwist/VectorPitch/SlopeFrontD
@onready var Back = $VectorTwist/VectorPitch/SlopeBackD
@onready var Left = $VectorTwist/VectorPitch/SlopeSideLD
@onready var Right = $VectorTwist/VectorPitch/SlopeSideRD
@onready var Center = $VectorTwist/VectorPitch/SlopeCenterD
@onready var SlopeRays = [Front, Back, Left, Right]
var first_landed : bool = false
var apply_acceleration : bool = false
var last_rotation : Vector3

const STRT_SPEED := 7
var SPEED_CAP := 40.4
var SPEED = STRT_SPEED
var LOSS_SPEED_WAlKING := 40
var LOSS_SPEED_BREAKS := 27.6
var LOSS_SPEED_RUNNING := 20
var RUNNING_STATE : bool = false
var COLLIDED_LAST_FRAME : bool = false
const ACCELERATION := 19.8

var LAST_GRAVITY = 0
var LAST_NORMAL : Vector3
const JUMP_STRT_SPEED := 30
const JUMP_SPEED_CAP := 35.32
const JUMP_ACC_DECEL := 200
var JUMP_ACCELERATION = JUMP_STRT_SPEED
var APPLIED_JUMP_ACCELERATION : float
var APPLIED_START_SPEED : float

var slide_collision_point : Vector3
var collision_normal : Vector3
var picked_push_dir := Vector3.ZERO
var last_frame_collision : bool
var normal_cast : Vector3
var angle : float

func _ready():
	floor_snap_length = 500
	floor_stop_on_slope = true
	slide_on_ceiling = true
	floor_constant_speed = true
	floor_max_angle = 88.9 * (PI/180)

func jump_input(delta) -> void:
	if Input.is_action_just_pressed("jump"):
		if not is_on_floor():
			$JumpBuffer.start(0.22)
		else:
			velocity.y = get_real_velocity().y
			velocity.y += JUMP_ACCELERATION / 3.01
			APPLIED_START_SPEED = velocity.y
			$JumpTimer.start(0.2)
	elif Input.is_action_pressed("jump"):
		if not $JumpTimer.is_stopped():
			if (APPLIED_JUMP_ACCELERATION < JUMP_SPEED_CAP + APPLIED_START_SPEED):
				JUMP_ACCELERATION -= JUMP_ACC_DECEL * delta
				APPLIED_JUMP_ACCELERATION += JUMP_ACCELERATION * delta
				velocity.y += APPLIED_JUMP_ACCELERATION
			else:
				APPLIED_JUMP_ACCELERATION = 0
				JUMP_ACCELERATION = JUMP_STRT_SPEED
				$JumpTimer.stop()
	elif Input.is_action_just_released("jump"):
		$JumpTimer.stop()
		APPLIED_JUMP_ACCELERATION = 0
		JUMP_ACCELERATION = JUMP_STRT_SPEED
	if not $JumpBuffer.is_stopped() and is_on_floor():
		$JumpTimer.start(0.2)

func rotation_lerp_zero(delta):
	$Graphic.rotation.x = lerp_angle($Graphic.rotation.x, 0, delta * 5.5)
	$VectorTwist.rotation.x = 0
	$Graphic.rotation.z = lerp_angle($Graphic.rotation.z, 0, delta * 5.5)
	$VectorTwist.rotation.z = 0

func lerp_from_last(delta):
	normal_cast = collision_normal
	normal_cast.z = 0
	angle = Vector3.UP.angle_to(normal_cast)
	if normal_cast.x > 0:
		angle = -angle
	$Graphic.rotation.z = lerp_angle($Graphic.rotation.z, angle, delta * 15)
	normal_cast.z = collision_normal.z
	normal_cast.x = 0
	angle = Vector3.UP.angle_to(normal_cast)
	if normal_cast.z < 0:
		angle = -angle
	$Graphic.rotation.x = lerp_angle($Graphic.rotation.x, angle, delta * 15)

func rotate_player_body(delta, mode : int, lerp_bool : bool):
	if mode == 1:
		collision_normal = Vector3.ZERO
		if Center.is_colliding():
			last_rotation = Center.get_collision_normal()
			if Front.is_colliding():
				for i in get_slide_collision_count():
					slide_collision_point = get_slide_collision(i).get_position()
					if slide_collision_point.distance_to(Center.get_collision_point()) > slide_collision_point.distance_to(Front.get_collision_point()):
						collision_normal = Front.get_collision_normal()
		else:
			velocity = get_real_velocity()
			set_motion_mode(MOTION_MODE_FLOATING)
			return
		if Center.is_colliding():
			if collision_normal == Vector3.ZERO:
				collision_normal = last_rotation
	elif mode == 0:
		collision_normal = get_floor_normal()
	elif mode == 2:
		collision_normal = Vector3.ZERO
		for i in 4:
			if SlopeRays[i].is_colliding():
				collision_normal = SlopeRays[i].get_collision_normal()
				break
		if collision_normal == Vector3.ZERO:
			collision_normal = get_floor_normal()
	normal_cast = collision_normal
	normal_cast.z = 0
	angle = Vector3.UP.angle_to(normal_cast)
	if normal_cast.x > 0:
		angle = -angle
	$VectorTwist.rotation.z = angle
	if lerp_bool == true:
		$Graphic.rotation.z = lerp_angle($Graphic.rotation.z, angle, delta * 15)
	normal_cast.z = collision_normal.z
	normal_cast.x = 0
	angle = Vector3.UP.angle_to(normal_cast)
	if normal_cast.z < 0:
		angle = -angle
	$VectorTwist.rotation.x = angle
	if lerp_bool == true:
		$Graphic.rotation.x = lerp_angle($Graphic.rotation.x, angle, delta * 15)

func directional_input(delta):
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	direction = Vector3(input_dir.x, 0, input_dir.y)
	if not hit_the_breaks:
		if direction == Vector3.ZERO and sqrt(pow(velocity.x, 2) + pow(velocity.z, 2)) <= 26.9:
			chosen_direction = Vector3.ZERO
		elif chosen_direction == Vector3.ZERO or sqrt(pow(velocity.x, 2) + pow(velocity.z, 2)) <= 26.9:
			direction = direction.rotated(Vector3.UP, get_parent().get_node("Twist").rotation.y)
			chosen_direction = direction
		elif direction != Vector3.ZERO:
			direction_rotated = direction.rotated(Vector3.UP, get_parent().get_node("Twist").rotation.y)
			chosen_direction = chosen_direction.lerp(direction_rotated, turning_speed * delta).normalized()
			if $VelocityVector.target_position.angle_to(direction_rotated) >= PI/2:
				hit_the_breaks = true
		else:
			chosen_direction = chosen_direction.lerp(direction_rotated, turning_speed * delta).normalized()
			if $VelocityVector.target_position.angle_to(direction_rotated) >= PI/2:
				hit_the_breaks = true
		if direction:
			SPEED = SPEED + (ACCELERATION * delta)
			if SPEED > SPEED_CAP:
				SPEED = SPEED_CAP
			velocity.x = chosen_direction.x * SPEED
			velocity.z = chosen_direction.z * SPEED
	if not direction:
		if SPEED > SPEED_CAP:
			SPEED = SPEED_CAP
		if sqrt(pow(velocity.x, 2) + pow(velocity.z, 2)) > 26.9:
			if not hit_the_breaks:
				SPEED = move_toward(SPEED, 0, LOSS_SPEED_RUNNING * delta)
				speed_loss_vector = Vector3(velocity.x, 0, velocity.z).move_toward(Vector3.ZERO, LOSS_SPEED_RUNNING * delta)
				velocity.x = speed_loss_vector.x
				velocity.z = speed_loss_vector.z
		else:
			SPEED = STRT_SPEED
			speed_loss_vector = Vector3(velocity.x, 0, velocity.z).move_toward(Vector3.ZERO, LOSS_SPEED_WAlKING * delta)
			velocity.x = speed_loss_vector.x
			velocity.z = speed_loss_vector.z
	if hit_the_breaks:
		speed_loss_vector = Vector3(velocity.x, 0, velocity.z).move_toward(Vector3.ZERO, LOSS_SPEED_BREAKS * delta)
		velocity.x = speed_loss_vector.x
		velocity.z = speed_loss_vector.z
		if (velocity.x + velocity.z) == 0:
			hit_the_breaks = false
			SPEED = STRT_SPEED

func directional_input_midair(delta):
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	direction = Vector3(input_dir.x, 0, input_dir.y)
	direction_rotated = direction.rotated(Vector3.UP, get_parent().get_node("Twist").rotation.y)
	velocity.x += direction_rotated.x * (ACCELERATION + 5.13) * delta
	velocity.z += direction_rotated.z * (ACCELERATION + 5.13) * delta
	
func rotate_based_on_velocity(delta):
	angle = Vector3.FORWARD.angle_to($VelocityVector.target_position)
	if Vector3.LEFT.angle_to($VelocityVector.target_position) > Vector3.RIGHT.angle_to($VelocityVector.target_position):
		angle = -angle
	$VectorTwist/VectorPitch.rotation.y = angle
	$Graphic/GraphicPitch.rotation.y = lerp_angle($Graphic.rotation.y, angle, delta * 15)

func _physics_process(delta):
	$VelocityVector.target_position.y = 0
	
	if Center.is_colliding() == true:
		set_motion_mode(MOTION_MODE_GROUNDED)
		apply_acceleration = false
	
	elif motion_mode == MOTION_MODE_FLOATING:
		if apply_acceleration:
			if not picked_push_dir:
				collision_normal = Vector3.ZERO
				if get_slide_collision_count() != 0:
					collision_normal = get_slide_collision(0).get_normal()
					collision_normal.y = 0
					collision_normal = collision_normal.normalized()
				if collision_normal == Vector3.ZERO:
					collision_normal = Front.get_collision_normal()
					collision_normal.y = 0
					collision_normal = collision_normal.normalized()
					if collision_normal == Vector3.ZERO:
						collision_normal = Back.get_collision_normal()
						collision_normal.y = 0
						collision_normal = collision_normal.normalized()
						if collision_normal == Vector3.ZERO:
							collision_normal = Back.get_collision_normal()
							collision_normal.y = 0
							collision_normal = collision_normal.normalized()
			else:
				collision_normal = picked_push_dir
			position.x += delta * collision_normal.x * 10
			position.z += delta * collision_normal.z * 10
		if get_slide_collision_count() == 0:
			set_motion_mode(MOTION_MODE_GROUNDED)
			apply_acceleration = false
		else:
			rotation_lerp_zero(delta)
	# Add the gravity.
	if not is_on_floor():
		first_landed = false
		if motion_mode == MOTION_MODE_GROUNDED:
			rotation_lerp_zero(delta)
		else:
			if is_on_wall():
				rotate_player_body(delta, 2, true)
				if get_real_velocity() == Vector3.ZERO:
					apply_acceleration = true
					collision_normal = get_slide_collision(0).get_normal()
					collision_normal.y = 0
					collision_normal = collision_normal.normalized()
					position.x += delta * collision_normal.x * 10
					position.z += delta * collision_normal.z * 10
		velocity.y -= gravity * delta 
	# Get jump related input and handle jumping behaviour.
	jump_input(delta)
	if motion_mode == MOTION_MODE_GROUNDED and is_on_floor():
		if not Input.is_action_just_pressed("jump"):
			apply_floor_snap()
		directional_input(delta)
	else:
		if sqrt(pow(velocity.x, 2) + pow(velocity.z, 2)) <= 4 and 4 >= sqrt(pow(velocity.x, 2) + pow(velocity.z, 2)):
			SPEED = STRT_SPEED
		directional_input_midair(delta)
		chosen_direction = velocity
		chosen_direction.y = 0
	# Get collision normal, collision angle and rotate body accordingly
	if is_on_floor():
		if first_landed == false:
			if not $JumpBuffer.is_stopped():
				velocity.y = 0
			$JumpTimer.stop()
			APPLIED_JUMP_ACCELERATION = 0
			JUMP_ACCELERATION = JUMP_STRT_SPEED
			first_landed = true
			if Center.is_colliding():
				rotate_player_body(delta, 1, false)
				Center.force_raycast_update()
				if not Center.is_colliding():
					rotate_player_body(delta, 0, true)
				else:
					lerp_from_last(delta)
			else:
				rotate_player_body(delta, 0, true)
				Center.force_raycast_update()
				Front.force_raycast_update()
				rotate_player_body(delta, 1, true)
		else:
			rotate_player_body(delta, 1, true)
		Center.force_raycast_update()
		if not Center.is_colliding():
			velocity = get_real_velocity()
			set_motion_mode(MOTION_MODE_FLOATING)
		else:
			LAST_NORMAL = collision_normal
	# Get movement direction related input and handle the velocity/acceleration.
	
	if (velocity.x + velocity.z) != 0:
		rotate_based_on_velocity(delta)
	$VelocityVector.target_position.x = velocity.x
	$VelocityVector.target_position.z = velocity.z
	$VelocityVector.target_position.y = velocity.y
	move_and_slide()

