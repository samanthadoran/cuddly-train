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

func determine_hex_rotation_in_radians() -> float:
	# Rotate in increments of pi/6 radians
	
	# TODO(Samantha): This should account for directional specials.
	# TODO(Samantha): This breaks for regular corners?
	
	const ROTATION_INCREMENT = PI / 3.0
	var first_connection = min(connections.path[0], connections.path[1])
	if connections.path_distance() > 3:
		first_connection = max(connections.path[0], connections.path[1])
	
	var steps_from_west = Path.Directions.W - first_connection
	return (steps_from_west * ROTATION_INCREMENT)

func _init(type: Hex_Type, mesh_lib: MeshLibrary, coordinates: Vector2i):
	# TODO(Samantha): Add a path argument
	hex_type = type
	mesh = MeshInstance3D.new()
	if type == Hex_Type.Playable or type == Hex_Type.Played:
		mesh.set_mesh(determine_hex_mesh(mesh_lib))
		mesh.rotate_y(determine_hex_rotation_in_radians())
	else:
		# Hard coded grass
		mesh.set_mesh(mesh_lib.get_item_mesh(0))
	offset_coordinates = coordinates
	mesh.visible = true
	visible = true
	add_child(mesh)
