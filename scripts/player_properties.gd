@icon("res://icons/nautilus.png")
extends Node3D
class_name PlayerProperties

var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

enum player_states {FLYING, GROUNDED, BREAKS, ACTION}
var player_state := player_states.FLYING

var input_dir : Vector3

@export var START_SPEED := 7.0
@export var JOG_START := 26.5
var will_hit_breaks : bool = true
@export var SPEED_CAP := 50.4
var SPEED = START_SPEED
@export var LOSS_WALKING := 40.0
@export var LOSS_BREAKS := 27.6
@export var LOSS_RUNNING := 20.0
var RUNNING_STATE : bool = false
var COLLIDED_LAST_FRAME : bool = false
@export var ACCELERATION := 19.8

@export var JUMP_START_SPEED := 30.0
@export var JUMP_SPEED_CAP := 40.0
@export var JUMP_DECELERATION := 380.0
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
var CollisionShape
var JumpTimer
var JumpBuffer
var ZeroGravity
var VectorTwist
var VectorPitch
var Front
var Back
var Left
var Right
var Center
var VelocityVector
var GraphicTwist
var Graphic

func _init():	
	CharacterBody = CharacterBody3D.new()
	add_child(CharacterBody)
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
	
	VectorTwist = Node3D.new()
	CharacterBody.add_child(VectorTwist)
	VectorPitch = Node3D.new()
	VectorTwist.add_child(VectorPitch)
	Front = RayCast3D.new()
	Front.target_position.y = -1.15
	Front.debug_shape_custom_color = Color(1, 1, 0)
	Back = RayCast3D.new()
	Back.target_position.y = -1.15
	Left = RayCast3D.new()
	Left.target_position.y = -1.15
	Right = RayCast3D.new()
	Right.target_position.y = -1.15
	Center = RayCast3D.new()
	Center.target_position.y = -1.15
	VectorPitch.add_child(Front)
	Front.position.z = -1
	VectorPitch.add_child(Back)
	Back.position.z = 1
	VectorPitch.add_child(Left)
	Left.position.x = -1
	VectorPitch.add_child(Right)
	Right.position.x = 1
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
	angle_z = vect1.angle_to(dir_cast)
	if dir_cast.x > 0:
		angle_z = -angle_z
	dir_cast.z = vect2.z
	dir_cast.x = 0
	angle_x = vect1.angle_to(dir_cast)
	if dir_cast.z < 0:
		angle_x = -angle_x
	return Vector3(angle_x, 0, angle_z)

func change_gravity(dir : Vector3):
	var angle_x_z : Vector3 = vector_angle_calculator(Vector3.UP, dir)
	gravity_last_angles.x = angle_x_z.x
	gravity_last_angles.z = angle_x_z.z
	VectorTwist.rotation.z = angle_x_z.z
	Graphic.rotation.z = angle_x_z.z
	VectorTwist.rotation.x = angle_x_z.x
	Graphic.rotation.x = angle_x_z.x
	CharacterBody.up_direction = dir
	
func horizontal_movement(delta):
	if input_dir:
		SPEED += ACCELERATION * delta
		if SPEED > JOG_START:
			if SPEED > SPEED_CAP:
				SPEED = move_toward(SPEED, SPEED_CAP, ACCELERATION * delta)
		chosen_dir = input_dir.rotated(Vector3.UP, CharacterBody.get_node("Camera").rotation.y)
	else:
		SPEED = START_SPEED
	horizontal_velocity = chosen_dir * SPEED
	horizontal_velocity = horizontal_velocity.rotated(Vector3.LEFT, -gravity_last_angles.x)
	horizontal_velocity = horizontal_velocity.rotated(Vector3.FORWARD, gravity_last_angles.z)
