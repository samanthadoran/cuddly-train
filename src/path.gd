extends Node

class_name Path

# TODO(Samantha): Might this more aptly be called connections?
enum Directions {NE, E, SE, SW, W, NW, ORIGIN, DESTINATION, UNCONNECTED}
enum RotationDirections {CLOCKWISE = 1, COUNTERCLOCKWISE = -1}

const NUMBER_OF_NONSPECIAL_DIRECTIONS = 6

var path: Array[Directions] = [Directions.UNCONNECTED, Directions.UNCONNECTED]

## Creates a direction "opposite" of the given one. A direction is "opposite" if it would be
## at the furthest point away from the other on a compass.
## Ex.) NE -> SW, E -> W, NW -> SE
static func make_opposite_direction(dir: Directions) -> Directions:
	return ((dir + 3) % NUMBER_OF_NONSPECIAL_DIRECTIONS) as Directions

## Determines if the current set of directions has an exact "opposite" to the passed direction.
## A direction is "opposite" if it would be at the furthest point away from the other on a compass.
## Ex.) NE -> SW, E -> W, NW -> SE
func has_opposite_direction(dir: Directions) -> bool:
	# Specials don't have an "opposite" direction.
	if dir >= Directions.ORIGIN:
		return false

	var opposite = make_opposite_direction(dir)

	return path[0] == opposite or path[1] == opposite

## Rotates a set of directions one step counterclockwise or clockwise. Does _not_ rotate
## special directions (ORIGIN, DESTINATION, UNCONNECTED).
## For example, rotating the set of directions [NW, NE] clockwise would yield [NE, E] and
## rotating the set of directions [NW, NE] counterclockwise would yield [W, NE].
func rotate(rotation_direction: RotationDirections):
	# TODO(Samantha): Figure out a more elegant way than all of these conditionals?
	# We cannot rotate specials
	if path[0] < Directions.ORIGIN:
		path[0] = ((path[0] + rotation_direction) % NUMBER_OF_NONSPECIAL_DIRECTIONS) as Directions
	if path[1] < Directions.ORIGIN:
		path[1] = ((path[1] + rotation_direction) % NUMBER_OF_NONSPECIAL_DIRECTIONS) as Directions

	# Unfortunately these are required becdause modulo doesn't work this way for negatives =(
	if path[0] < 0:
		path[0] = (NUMBER_OF_NONSPECIAL_DIRECTIONS + path[0]) as Directions
	if path[1] < 0:
		path[1] = (NUMBER_OF_NONSPECIAL_DIRECTIONS + path[1]) as Directions

	normalize_path()

func _init(first_direction: Directions = Directions.UNCONNECTED, second_direction: Directions = Directions.UNCONNECTED):
	path = [first_direction, second_direction]
	normalize_path()

## Performs normalization (really canonicalization) on a path, a set of directions.
## This first makes sure that any directional specials (ORIGIN, DESTINATION, UNCONNECTED) are
## always first. The first should always be the direction closest to NE.
## Ex.) [W, NE] -> [NE, W].
## There is a special case when the directions cross North on a compass,
## that is, when the path distance is greater than 3 like in the case of [NE, NW] in which the first direction
## will be the closest (without going over) NW.
## Ex.) [NE, NW] -> [NW, NE]
func normalize_path():
	# TODO(Samantha): This should set the connections in a canonical order.
	# This should be such that if a corner crosses the directional origin
	# ex: (NE, NW), the first should always be NE



	# Specials are always the first connection. This is already normalized.
	if path[0] >= Directions.ORIGIN:
		return
	# Specials _must_ be the first connection.
	if path[1] >= Directions.ORIGIN:
		# This silently handles the case of both directions being specials...
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

func is_unconnected() -> bool:
	return path[0] == Directions.UNCONNECTED or path[1] == Directions.UNCONNECTED

func is_origin_or_destination() -> bool:
	return path[0] >= Directions.ORIGIN or path[1] >= Directions.ORIGIN

## Calculates the distance between two directions in a path. Directions are assigned a value
## between [0, 5], and the results will be within that same range.
func path_distance() -> int:
	var first_direction = path[0]
	var second_direction = path[1]
	var distance = abs(first_direction - second_direction)
	return distance
