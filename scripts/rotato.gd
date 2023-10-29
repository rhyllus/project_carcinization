extends MeshInstance3D

func _physics_process(delta):
	rotation.y += 1 * delta
