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
var origin_hex: Hex

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
	if event.is_action_pressed("show_score"):
		calculate_score()
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

func _make_origin_hex(offset_coordinates: Vector2i) -> Hex:
	var connected_direction: Path.Directions = (randi() % Path.NUMBER_OF_NONSPECIAL_DIRECTIONS) as Path.Directions
	var path = Path.new(Path.Directions.ORIGIN, connected_direction)
	return Hex.new(Hex.Hex_Type.Unplayable, unplaceable_tile_library, offset_coordinates, path)

func walk_graph(hex: Hex, from: Path.Directions = Path.Directions.ORIGIN) -> int:
	# TODO(Samantha): This doesn't sanity check a hex having a malformed path.
	# Garbage in, garbage out, I guess.
	assert(not hex.connections.is_unconnected(), "How are we at a node with an unconnected part?")
	assert(not hex.connections.path[0] == hex.connections.path[1], "What does it even mean for the same direction to have two connections?")

	var neighbors = get_neighbors(hex)

	# We only want to check in the direction that we weren't just at!
	var index_of_from = hex.connections.path.find(from)
	var direction_to_check = hex.connections.path[(index_of_from + 1) % 2]
	print("Was From: %s \t Checking direction: %s" % [Path.Directions.find_key(from), Path.Directions.find_key(direction_to_check)])

	if neighbors.has(direction_to_check):
		var neighbor: Hex = neighbors[direction_to_check]
		if neighbor.connections.has_opposite_direction(direction_to_check):
				return 1 + (walk_graph(neighbor, Path.make_opposite_direction(direction_to_check)))
	return 0

func calculate_score():
	var score = walk_graph(origin_hex)
	print("Your score is: %s" % score)

func _generate_hex_grid():
	origin_hex = _make_origin_hex(Vector2i(grid_width/2, grid_length/2))
	for y in grid_length:
		for x in grid_width:
			if Vector2i(x, y) == origin_hex.offset_coordinates:
				add_child(origin_hex)
				grid[origin_hex.offset_coordinates] = origin_hex
				origin_hex.translate(odd_row_right_hex_to_pixel(origin_hex))
				continue
			var hex = create_hex(Hex.Hex_Type.Unplayable, unplaceable_tile_library, Vector2i(x, y))
			add_child(hex)
			grid[hex.offset_coordinates] = hex
			hex.translate(odd_row_right_hex_to_pixel(hex))


# TODO(Samantha): Raycast onto invisible/transparent hexes to select which one the user can place?

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

func get_neighbors(hex: Hex) -> Dictionary:
	var neighbors = {}
	var neighbor_locations = oddr_offset_neighbors_coordinates(hex)
	for i in range(6):
		if grid.has(neighbor_locations[i]):
			neighbors[i as Path.Directions] = grid[neighbor_locations[i]]
	return neighbors
