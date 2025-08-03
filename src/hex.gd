extends Node3D

class_name Hex

enum Hex_Type {Playable, Unplayable, Played}
enum Modifier {Base, Bonus, Penalty}
var mesh: MeshInstance3D
var offset_coordinates: Vector2i
var hex_type: Hex_Type
var connections: Path = Path.new()
var modifier: Modifier

#enum Directions {NE, E, SE, SW, W, NW}

func determine_hex_mesh(mesh_lib: MeshLibrary) -> Mesh:
	var mesh_lib_index = 0
	match connections.path_distance():
		0:
			push_error("To itself?")
		1, 5:
			mesh_lib_index = mesh_lib.find_item_by_name("river_corner_sharp")
		2, 4:
			mesh_lib_index = mesh_lib.find_item_by_name("river_corner")
		3: 
			mesh_lib_index = mesh_lib.find_item_by_name("river_straight")
	
	return mesh_lib.get_item_mesh(mesh_lib_index)

func determine_hex_rotation() -> int:
	match connections.path_distance():
		# Sharp
		1, 5:
			pass
		# Regular Corner
		2, 4:
			pass
		# Straight
		3:
			pass
	return 0

func _init(type: Hex_Type, mesh_lib: MeshLibrary, coordinates: Vector2i):
	hex_type = type
	mesh = MeshInstance3D.new()
	if type == Hex_Type.Playable or type == Hex_Type.Played:
		mesh.set_mesh(determine_hex_mesh(mesh_lib))
	else:
		# Hard coded grass
		mesh.set_mesh(mesh_lib.get_item_mesh(0))
	offset_coordinates = coordinates
	mesh.visible = true
	visible = true
	add_child(mesh)
