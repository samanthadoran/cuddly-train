extends Node3D

class_name Hex

enum Hex_Type {Playable, Unplayable, Played}
enum Modifier {Base, Bonus, Penalty}
var mesh: MeshInstance3D
var offset_coordinates: Vector2i
var hex_type: Hex_Type
var connections: Path = Path.new()
var modifier: Modifier

## Rotates a hex one step in either a clockwise or counterclockwise direction.
## This applys rotation to the model and to the internal path connections.
func rotate_hex(direction: Path.RotationDirections):
	# TODO(Samantha): Should this be moved out to hex grid? It's not doing much heavy lifting.
	connections.rotate(direction)
	mesh.rotation = Vector3(0, determine_hex_rotation_in_radians(), 0)

func determine_hex_mesh(mesh_lib: MeshLibrary) -> Mesh:
	var mesh_lib_index = 0

	if connections.is_unconnected():
		mesh_lib_index = mesh_lib.find_item_by_name("grass")
		return mesh_lib.get_item_mesh(mesh_lib_index)

	if connections.is_origin_or_destination():
		mesh_lib_index = mesh_lib.find_item_by_name("river_start")
		return mesh_lib.get_item_mesh(mesh_lib_index)

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


## Determines the amount of rotation to apply to a given hex's mesh based upon
## its type and connections. This is necessary to align the internal representation with what the
## user sees.
func determine_hex_rotation_in_radians() -> float:
	# Rotate in increments of pi/6 radians
	
	# This is a "grass" or unplayed, apply no rotation.
	if connections.is_unconnected():
		return 0
	
	const ROTATION_INCREMENT = PI / 3.0
	var first_connection = min(connections.path[0], connections.path[1])
	if connections.path_distance() > 3:
		first_connection = max(connections.path[0], connections.path[1])

	# We cannot rotate an origin or destination, rotate it by moving the edge connection.
	if connections.is_origin_or_destination():
		first_connection = connections.path[1]

	var steps_from_west = Path.Directions.W - first_connection
	return (steps_from_west * ROTATION_INCREMENT)

func _init(type: Hex_Type, mesh_lib: MeshLibrary, coordinates: Vector2i, path: Path = Path.new(Path.Directions.UNCONNECTED, Path.Directions.UNCONNECTED)):
	hex_type = type
	connections = path
	mesh = MeshInstance3D.new()
	mesh.set_mesh(determine_hex_mesh(mesh_lib))
	mesh.rotate_y(determine_hex_rotation_in_radians())
	offset_coordinates = coordinates
	mesh.visible = true
	visible = true
	add_child(mesh)
