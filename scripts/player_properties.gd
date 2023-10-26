@icon("res://icons/nautilus.png")
extends Node3D
class_name PlayerProperties

var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

enum player_states {FLYING, GROUNDED, NODIR, ACTION}
var player_state := player_states.FLYING

var input_dir : Vector3

@export var START_SPEED := 7.0
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

var pulse_velocity : float
var pulse_direction : Vector3 = Vector3.ZERO

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
	Back = RayCast3D.new()
	Left = RayCast3D.new()
	Right = RayCast3D.new()
	Center = RayCast3D.new()
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

func _ready():
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
	
func impulse(dir : Vector3, strength : float, time : float):
	pulse_velocity = strength
	pulse_direction = Vector3(dir.x * strength, dir.y * strength, dir.z * strength)
	if time != 0:
		ZeroGravity.start(time)
	
func get_directional_input():
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	input_dir = Vector3(input.x, 0, input.y)
	
func get_action_input(delta):
	pass
	
func change_gravity(angle_x : float, angle_z : float):
	angle_x = rad_to_deg(angle_x)
	angle_z = rad_to_deg(angle_z)
	VectorTwist.rotation.x = angle_x
	VectorTwist.rotation.z = angle_z
	var dir : Vector3 = Vector3.UP.rotated(Vector3.FORWARD, angle_x)
	dir = dir.rotated(Vector3.LEFT, angle_z)
	CharacterBody.up_direction = dir
