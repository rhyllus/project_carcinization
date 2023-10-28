@icon("res://icons/nautilus.png")
extends Node3D
class_name PlayerProperties

var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

enum player_states {FLYING, GROUNDED, BREAKS, ACTION, FLOATING}
var player_state := player_states.FLYING

var input_dir : Vector3

@export var START_SPEED := 7.0
@export var JOG_START := 26.5
@export var SPEED_CAP := 50.4
var SPEED = START_SPEED
@export var LOSS_WALKING := 50
@export var LOSS_BREAKS := 35
@export var LOSS_RUNNING := 20.0
var RUNNING_STATE : bool = false
var COLLIDED_LAST_FRAME : bool = false
@export var ACCELERATION := 19.8
@export var TURNING_SPEED := 4.8
var is_on_wall_extra : bool = false

@export var JUMP_START_SPEED := 500.0
@export var JUMP_DECELERATION := 3600.0
var JUMP_VELOCITY = JUMP_START_SPEED
var APPLIED_JUMP_ACCELERATION : float
var APPLIED_START_SPEED : float
@export var JUMP_TIME := 2.0
@export var JUMP_BUFFER_TIME := 0.15

var pulse_dir : Vector3 = Vector3.ZERO
var chosen_dir : Vector3 = Vector3.ZERO
var horizontal_velocity: Vector3 = Vector3.ZERO
var gravity_last_angles : Vector3 = Vector3(0, 0, 0)

var CharacterBody
var HorizontalMidair
var CollisionShape
var JumpTimer
var JumpBuffer
var ZeroGravity
var VectorTwist_x
var VectorTwist_z
var VectorPitch
var Front
var Back
var Left
var Left2
var Right
var Right2
var Center
var VelocityVector
var GraphicTwist
var Graphic

func _init():	
	CharacterBody = CharacterBody3D.new()
	add_child(CharacterBody)
	HorizontalMidair = CharacterBody3D.new()
	CharacterBody.add_child(HorizontalMidair)
	CollisionShape = CollisionShape3D.new()
	CollisionShape.shape = SphereShape3D.new()
	CollisionShape.shape.radius = 1
	CharacterBody.add_child(CollisionShape)
	
	JumpTimer = Timer.new()
	JumpTimer.one_shot = true
	JumpBuffer = Timer.new()
	JumpBuffer.one_shot = true
	ZeroGravity = Timer.new()
	ZeroGravity.one_shot = true
	CharacterBody.add_child(JumpTimer)
	CharacterBody.add_child(JumpBuffer)
	CharacterBody.add_child(ZeroGravity)
	
	VectorTwist_x = Node3D.new()
	CharacterBody.add_child(VectorTwist_x)
	VectorTwist_z = Node3D.new()
	VectorTwist_x.add_child(VectorTwist_z)
	VectorPitch = Node3D.new()
	VectorTwist_z.add_child(VectorPitch)
	Front = RayCast3D.new()
	Front.target_position.y = -1.15
	Front.debug_shape_custom_color = Color(1, 1, 0)
	Back = RayCast3D.new()
	Back.target_position.y = -1.15
	Left = RayCast3D.new()
	Left.target_position.y = -1.15
	Left2 = RayCast3D.new()
	Left2.target_position.y = -1.15
	Right = RayCast3D.new()
	Right.target_position.y = -1.15
	Right2 = RayCast3D.new()
	Right2.target_position.y = -1.15
	Center = RayCast3D.new()
	Center.target_position.y = -1.15
	VectorPitch.add_child(Front)
	Front.position.z = -1
	VectorPitch.add_child(Back)
	Back.position.z = 1
	VectorPitch.add_child(Left)
	Left.position.x = -1
	VectorPitch.add_child(Left2)
	Left2.position.x = 0.75
	Left2.position.z = -0.75
	VectorPitch.add_child(Right)
	Right.position.x = 1
	VectorPitch.add_child(Right2)
	Right2.position.x = -0.75
	Right2.position.z = -0.75
	VectorPitch.add_child(Center)
	
	VelocityVector = RayCast3D.new()
	VelocityVector.debug_shape_custom_color = Color(0.9, 0.2, 0.8)
	VelocityVector.collide_with_bodies = false
	CharacterBody.add_child(VelocityVector)
	
	GraphicTwist = Node3D.new()
	CharacterBody.add_child(GraphicTwist)
	Graphic = MeshInstance3D.new()
	Graphic.mesh = CapsuleMesh.new()
	GraphicTwist.add_child(Graphic)
	Graphic.mesh.radius = 0.5
	Graphic.mesh.height = 2
	
func impulse(dir : Vector3, strength : float, time : float):
	pulse_dir = dir * strength
	if time != 0:
		ZeroGravity.start(time)
	return pulse_dir

func apply_gravity(delta):
	var gravity_direction = CharacterBody.up_direction
	gravity_direction = -gravity_direction * gravity * delta
	CharacterBody.velocity += gravity_direction

func get_directional_input():
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	input_dir = Vector3(input.x, 0, input.y)
	
func get_action_input(delta):
	pass

func vector_angle_calculator(vect1 : Vector3, vect2 : Vector3):
	var dir_cast = vect2
	var angle_x : float
	var angle_z : float
	dir_cast.z = 0
	angle_z = vect1.angle_to(dir_cast.normalized())
	if dir_cast.x > 0:
		angle_z = -angle_z
	dir_cast.z = vect2.z
	dir_cast.x = 0
	angle_x = vect1.angle_to(dir_cast.normalized())
	if dir_cast.z < 0:
		angle_x = -angle_x
	return Vector3(angle_x, 0, angle_z)

func change_gravity(dir : Vector3) -> void:
	var angle_x_z : Vector3 = vector_angle_calculator(Vector3.UP, dir)
	gravity_last_angles.x = angle_x_z.x
	gravity_last_angles.z = -angle_x_z.z
	VectorTwist_z.rotation.z = gravity_last_angles.z
	Graphic.rotation.z = gravity_last_angles.z
	VectorTwist_x.rotation.x = gravity_last_angles.x
	Graphic.rotation.x = gravity_last_angles.x
	CharacterBody.up_direction = dir

func movement_reset() -> void:
	SPEED = START_SPEED
	chosen_dir = Vector3.ZERO

func breaks(delta) -> void:
	horizontal_velocity = horizontal_velocity.move_toward(Vector3.ZERO, LOSS_BREAKS * delta)
	CharacterBody.velocity = horizontal_velocity
	if horizontal_velocity == Vector3.ZERO:
		player_state = player_states.GROUNDED
		movement_reset()

func horizontal_movement(delta) -> void:
	if input_dir:
		if SPEED < START_SPEED:
			SPEED = START_SPEED
		SPEED += ACCELERATION * delta
		if SPEED > JOG_START:
			var input_rotated = input_dir.rotated(Vector3.UP, CharacterBody.get_node("Camera").rotation.y)
			if SPEED > SPEED_CAP:
				SPEED = move_toward(SPEED, SPEED_CAP, ACCELERATION * delta)
			chosen_dir = chosen_dir.lerp(input_rotated, TURNING_SPEED * delta)
			if VelocityVector.target_position.angle_to(input_rotated) >= (PI * 0.6):
				player_state = player_states.BREAKS
				return
		else:
			chosen_dir = input_dir.rotated(Vector3.UP, CharacterBody.get_node("Camera").rotation.y)
	else:
		if SPEED > JOG_START:
			SPEED = move_toward(SPEED, 0, LOSS_RUNNING * delta)
		else:
			SPEED = move_toward(SPEED, 0, LOSS_WALKING * delta)
			if SPEED == 0:
				movement_reset()
	horizontal_velocity = chosen_dir * SPEED
	if gravity_last_angles.x > 0:
		horizontal_velocity = horizontal_velocity.rotated(Vector3.FORWARD, -gravity_last_angles.z)
	else:
		horizontal_velocity = horizontal_velocity.rotated(Vector3.FORWARD, gravity_last_angles.z)
	if gravity_last_angles.z < 0:
		horizontal_velocity = horizontal_velocity.rotated(Vector3.LEFT, gravity_last_angles.x)
	else:
		horizontal_velocity = horizontal_velocity.rotated(Vector3.LEFT, -gravity_last_angles.x)

func compare_center_to_ray(ray : RayCast3D):
	if ray.is_colliding():
		for i in CharacterBody.get_slide_collision_count():
			var slide_collision_point = CharacterBody.get_slide_collision(i).get_position()
			if slide_collision_point.distance_to(Center.get_collision_point()) > slide_collision_point.distance_to(ray.get_collision_point()):
				return ray.get_collision_normal()
	return Vector3.ZERO
	
func rotate_player_body(delta, mode : int, lerp_bool : bool) -> void:
	var collision_normal : Vector3
	if mode == 1:
		collision_normal = Vector3.ZERO
		var last_rotation : Vector3 = Center.get_collision_normal()
		collision_normal = compare_center_to_ray(Front)
		if collision_normal == Vector3.ZERO:
			collision_normal = compare_center_to_ray(Left)
			if collision_normal == Vector3.ZERO:
				collision_normal = compare_center_to_ray(Right)
				if collision_normal == Vector3.ZERO:
					collision_normal = compare_center_to_ray(Left2)
					if collision_normal == Vector3.ZERO:
						collision_normal = compare_center_to_ray(Right2)
		if Center.is_colliding():
			if collision_normal == Vector3.ZERO:
				collision_normal = last_rotation
		else:
			player_state = player_states.FLOATING
			CharacterBody.velocity = CharacterBody.get_real_velocity()
			return
	elif mode == 0:
		collision_normal = CharacterBody.get_floor_normal()
	var angle_x_z : Vector3 = vector_angle_calculator(Vector3.UP, collision_normal)
	if lerp_bool:
		Graphic.rotation.x = lerp_angle(Graphic.rotation.x, angle_x_z.x + (gravity_last_angles.x * 2), 15 * delta)
		Graphic.rotation.z = lerp_angle(Graphic.rotation.z, angle_x_z.z + (gravity_last_angles.z * 2), 15 * delta)
	VectorTwist_x.rotation.x = angle_x_z.x + (gravity_last_angles.x * 2)
	VectorTwist_z.rotation.z = angle_x_z.z + (gravity_last_angles.z * 2)

func jump_input(delta) -> void:
	if Input.is_action_just_pressed("jump"):
		if not CharacterBody.is_on_floor():
			JumpBuffer.start(0.22)
		elif CharacterBody.is_on_floor():
			CharacterBody.velocity.y = CharacterBody.get_real_velocity().y
			CharacterBody.velocity.y += JUMP_VELOCITY * delta
			APPLIED_START_SPEED = CharacterBody.velocity.y
			JumpTimer.start(0.2)
	elif Input.is_action_pressed("jump") and not JumpTimer.is_stopped():
		JUMP_VELOCITY = move_toward(JUMP_VELOCITY, 0, JUMP_DECELERATION * delta)
		CharacterBody.velocity.y += JUMP_VELOCITY * delta
	elif Input.is_action_just_released("jump"):
		JumpTimer.stop()
		APPLIED_JUMP_ACCELERATION = 0
		CharacterBody.velocity.y -= JUMP_VELOCITY * delta
		JUMP_VELOCITY = JUMP_START_SPEED
	if not JumpBuffer.is_stopped() and CharacterBody.is_on_floor():
		JumpTimer.start(0.3)

func rotate_based_on_velocity(delta):
	var angle = Vector3.FORWARD.angle_to(VelocityVector.target_position)
	if Vector3.LEFT.angle_to(VelocityVector.target_position) > Vector3.RIGHT.angle_to(VelocityVector.target_position):
		angle = -angle
	VectorPitch.rotation.y = angle
	Graphic.rotation.y = lerp_angle(GraphicTwist.rotation.y, angle, delta * 15)
	
func rotation_reset(delta):
	Graphic.rotation.x = lerp_angle(Graphic.rotation.x, gravity_last_angles.x, delta * 5)
	VectorTwist_x.rotation.x = gravity_last_angles.x
	Graphic.rotation.z = lerp_angle(Graphic.rotation.z, gravity_last_angles.z, delta * 5)
	VectorTwist_z.rotation.z = gravity_last_angles.z
