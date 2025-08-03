extends Node

class_name Path

enum Directions {NE, E, SE, SW, W, NW, ORIGIN, DESTINATION, UNCONNECTED}

@export var path: Array[Directions] = [Directions.UNCONNECTED, Directions.UNCONNECTED]

func path_distance() -> int:
	var first_direction = path[0]
	var second_direction = path[1]
	var distance = abs(first_direction - second_direction)
	return distance
