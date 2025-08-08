extends Node3D

class_name Hex_Grid

#enum Hex_Type {Playable, Unplayable, Played}

var hex_rivers: Array[Hex] = []

var hex_rivers_size := hex_rivers.size()
const HEX_SCALE := 1.0

@export var grid_width := 5
@export var grid_length := 5
@export var placeable_tile_library: MeshLibrary = preload("res://assets/mesh_libraries/placeables.tres")
@export var unplaceable_tile_library: MeshLibrary = preload("res://assets/mesh_libraries/unplaceables.tres")
var grid = {}
var selection = Vector2i.ZERO

const HEX = preload("res://scenes/hex/hex.tscn")

func play_hex(hex: Hex):
	hex.hex_type = Hex.Hex_Type.Played
	var first_dir: Path.Directions = (randi() % Path.NUMBER_OF_NONSPECIAL_DIRECTIONS) as Path.Directions
	# Make sure the second direction can't be equal to the first.
	var second_dir: Path.Directions = ((first_dir + randi_range(1, 5)) % Path.NUMBER_OF_NONSPECIAL_DIRECTIONS) as Path.Directions

	hex.connections = Path.new(first_dir, second_dir)
	hex.mesh.set_mesh(hex.determine_hex_mesh(placeable_tile_library))
	
	# Zero the rotation in case we ever allow playing over played hexes.
	hex.mesh.rotation = Vector3(0,0,0)
	hex.mesh.rotate_y(hex.determine_hex_rotation_in_radians())

func _input(event: InputEvent) -> void:
	# TODO(Samantha): There has to be a better way than an if/else chain.
	if event.is_action_pressed("ui_left"):
		if selection.x > 0:
			selection.x -= 1
	if event.is_action_pressed("ui_right"):
		if selection.x < grid_width - 1:
			selection.x += 1
	if event.is_action_pressed("ui_up"):
		if selection.y > 0:
			selection.y -= 1
	if event.is_action_pressed("ui_down"):
		if selection.y < grid_length - 1:
			selection.y += 1
	if event.is_action_pressed("ui_accept"):
		play_hex(grid[selection])
		
	# TODO(Samantha): These are mapped to Shift + R and R, without the returns, they both trigger??
	if event.is_action_pressed("rotate_hex_counterclockwise"):
		grid[selection].rotate_hex(Path.RotationDirections.COUNTERCLOCKWISE)
		return
	if event.is_action_pressed("rotate_hex_clockwise"):
		grid[selection].rotate_hex(Path.RotationDirections.CLOCKWISE)
		return

func _ready() -> void:
	_generate_hex_grid()

func create_hex(type: Hex.Hex_Type, mesh_lib: MeshLibrary, pos: Vector2i):
	return Hex.new(type, mesh_lib, pos)

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
			grid[hex.offset_coordinates] = hex
			hex.translate(odd_row_right_hex_to_pixel(hex))

# TODO(Samantha): Raycast onto invisible/transparent hexes to select which one the user can place?

#enum Directions {NE, E, SE, SW, W, NW}

const oddr_direction_differences = [
	# Even Rows
	#     NE               E               SE
	[Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1),
	#     SW               W               NW
	Vector2i(-1, 1), Vector2i(-1, 0), Vector2i(-1, -1)],
	# Odd Rows
	#     NE               E               SE
	[Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1),
	#     SW               W               NW
	Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]
]

func oddr_offset_neighbors_coordinates(hex: Hex) -> Array[Vector2i]:
	var coords = hex.offset_coordinates
	var result: Array[Vector2i] = []
	for direction in oddr_direction_differences[0 if coords.y % 2 == 0 else 1]:
		result.append(coords + direction)
	return result
