extends Node3D

class_name Hex

enum Hex_Type {Playable, Unplayable, Played}
enum Modifier {Base, Bonus, Penalty}
var mesh: MeshInstance3D
var offset_coordinates: Vector2i
var hex_type: Hex_Type
var connections: Array = [Path]
var modifier: Modifier

func _init(type: Hex_Type, mesh_lib: MeshLibrary, coordinates: Vector2i):
	mesh = MeshInstance3D.new()
	mesh.set_mesh(mesh_lib.get_item_mesh(0))
	hex_type = type
	offset_coordinates = coordinates
	mesh.visible = true
	visible = true
	add_child(mesh)
