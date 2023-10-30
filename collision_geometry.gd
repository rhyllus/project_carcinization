extends StaticBody3D
class_name CollisionGeometry


@onready var mesh: Mesh = $Cube.mesh
var mesh_data: MeshDataTool

func _ready() -> void:
	mesh_data = MeshDataTool.new()
	mesh_data.create_from_surface(mesh, 0)


func get_vertex_normals_at_face_index(index: float) -> Array[Vector3]:
	var normals: Array[Vector3] = []
	for i in range(0, 3):
		normals.append(mesh_data.get_vertex_normal(mesh_data.get_face_vertex(index, i)))
	return normals

func get_vertex_positions_at_face_index(index: float) -> Array[Vector3]:
	var vertices: Array[Vector3] = []
	for i in range(0, 3):
		vertices.append(mesh_data.get_vertex(mesh_data.get_face_vertex(index, i)))
	return vertices
