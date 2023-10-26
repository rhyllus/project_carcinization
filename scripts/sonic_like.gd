@icon("res://icons/sonic_like.png")
extends PlayerProperties
class_name SonicLike

func _physics_process(delta):
	if pulse_velocity == 0 and player_state == player_states.FLYING:
		impulse(Vector3(0, -1, 0), gravity * delta, 0) 
		CharacterBody.velocity += pulse_direction
	else:
		if not CharacterBody.is_on_floor():
			CharacterBody.velocity += pulse_direction
		else:
			CharacterBody.velocity = Vector3.ZERO
	CharacterBody.move_and_slide()
