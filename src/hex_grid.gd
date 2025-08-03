extends Node3D

class_name Hex_Grid

#enum Hex_Type {Playable, Unplayable, Played}

var hex_rivers: Array[Hex] = []

var hex_rivers_size := hex_rivers.size()
const HEX_SCALE := 1.0

enum Directions {NE, E, SE, SW, W, NW}

@export var grid_width := 5
@export var grid_length := 5
@export var placeable_tile_library: MeshLibrary = preload("res://assets/mesh_libraries/placeables.tres")
@export var unplaceable_tile_library: MeshLibrary = preload("res://assets/mesh_libraries/unplaceables.tres")

const HEX = preload("res://scenes/hex/hex.tscn")

func _ready() -> void:
	_generate_hex_grid()

func create_hex(type: Hex.Hex_Type, mesh_lib: MeshLibrary, pos: Vector2i):
	return Hex.new(int(type), mesh_lib, pos)

#function oddr_offset_to_pixel(hex):
	#// hex to cartesian
	#var x = sqrt(3) * (hex.col + 0.5 * (hex.row&1))
	#var y =    3./2 * hex.row
	#// scale cartesian coordinates
	#x = x * size
	#y = y * size
	#return Point(x, y)

func odd_row_right_hex_to_pixel(hex) -> Vector3:
	var coords = hex.offset_coordinates
	var x = sqrt(3) * (coords.x + 0.5 * (0 if coords.y % 2 == 0 else 1))
	var y = 3.0/2.0 * coords.y
	x = x * .576
	y = y * .576
	return Vector3(x, 0, y)

func _generate_hex_grid():
	for y in grid_length:
		for x in grid_width:
			var hex = create_hex(Hex.Hex_Type.Unplayable, unplaceable_tile_library, Vector2i(x, y))
			add_child(hex)
			hex.translate(odd_row_right_hex_to_pixel(hex))

# TODO(Samantha): Raycast onto invisible/transparent hexes to select which one the user can place?

#var oddr_direction_differences = [
	#// even rows 
	#[[+1,  0], [ 0, -1], [-1, -1], 
	 #[-1,  0], [-1, +1], [ 0, +1]],
	#// odd rows 
	#[[+1,  0], [+1, -1], [ 0, -1], 
	 #[-1,  0], [ 0, +1], [+1, +1]],
#]
#
#function oddr_offset_neighbor(hex, direction):
	#var parity = hex.row & 1
	#var diff = oddr_direction_differences[parity][direction]
	#return OffsetCoord(hex.col + diff[0], hex.row + diff[1])
	
const oddr_direction_differences = [
	# Even Rows
	[Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)],
	# Odd Rows
	[Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(0, 1), Vector2i(1, 1)]
]

func oddr_offset_neighbors_coordinates(hex: Hex) -> Array[Vector2i]:
	var coords = hex.offset_coordinates
	var result = []
	for direction in oddr_direction_differences[0 if hex.row % 2 == 0 else 1]:
		result.append(coords + direction)
	return result

#func position_to_xyz(hex: Hex) -> Vector3:
	#var cube_coordinates = hex.cube_coordinates
	#var x = sqrt(3) * cube_coordinates.x + sqrt(3)/2.0 * cube_coordinates.y
	#var y = 3.0 / 2.0 * cube_coordinates.y
	#return Vector3(x,0,y)
#
#const DIRECTION_VECTORS = [Vector3i(1,0,-1),
	#Vector3i(1,-1,0), 
	#Vector3i(0,-1,1),
	#Vector3i(-1,0,1),
	#Vector3i(-1,1,0),
	#Vector3i(0,1,-1)]
#
#func neighbour_locations(hex: Hex) -> Array[Vector3i]:
	#var cube_coordinates = hex.cube_coordinates
	#var result = []
	#for direction in DIRECTION_VECTORS:
		#result.add(cube_coordinates + direction)
	#return result
