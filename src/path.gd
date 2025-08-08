extends Node

class_name Path

enum Directions {NE, E, SE, SW, W, NW, ORIGIN, DESTINATION, UNCONNECTED}
enum RotationDirections {CLOCKWISE = 1, COUNTERCLOCKWISE = -1}

const NUMBER_OF_NONSPECIAL_DIRECTIONS = 6

var path: Array[Directions] = [Directions.UNCONNECTED, Directions.UNCONNECTED]

func rotate(direction: RotationDirections):
	# We cannot rotate specials
	if path[0] < Directions.ORIGIN:
		path[0] = ((path[0] + direction) % NUMBER_OF_NONSPECIAL_DIRECTIONS) as Directions
	path[1] = ((path[1] + direction) % NUMBER_OF_NONSPECIAL_DIRECTIONS) as Directions
	normalize_path()

func _init(first_direction: Directions = Directions.UNCONNECTED, second_direction: Directions = Directions.UNCONNECTED):
	path = [first_direction, second_direction]
	if first_direction < Directions.ORIGIN and second_direction < Directions.ORIGIN:
		normalize_path()

func normalize_path():
	# TODO(Samantha): This should set the connections in a canonical order.
	# This should be such that if a corner crosses the directional origin
	# ex: (NE, NW), the first should always be NE
	
	# Specials are always the first connection. This is already normalized.
	if path[0] >= Directions.ORIGIN:
		return
	# Specials _must_ be the first connection.
	if path[1] >= Directions.ORIGIN:
		var canon_first_dir = path[1]
		var canon_second_dir = path[0]
		path = [canon_first_dir, canon_second_dir]
	
	# If we're crossing the directional origin...
	if path_distance() > 3:
		var canon_first_dir = max(path[0], path[1])
		var canon_second_dir = min(path[0], path[1])
		path = [canon_first_dir, canon_second_dir]
	else:
		# Otherwise, the first connection is always the one numerically closer to NE
		var canon_first_dir = min(path[0], path[1])
		var canon_second_dir = max(path[0], path[1])
		path = [canon_first_dir, canon_second_dir]

func path_distance() -> int:
	var first_direction = path[0]
	var second_direction = path[1]
	var distance = abs(first_direction - second_direction)
	return distance
