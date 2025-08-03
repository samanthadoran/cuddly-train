extends Node3D

# This will be where we switch levels by trashing our old level and loading a new scene with ctor parameters

# There is a function for changing scenes manually

 # Preload the scene and call .instantiate get_tree

#const LEVEL_SCENE = preload("res://hex/hex_grid.tscn")
#
#func _ready():
	#var level_to_load = LEVEL_SCENE.instantiate()
	#add_child(level_to_load.instantiate())
#
#func change_scene_to_node(node):
	#var tree = get_tree()
	#var cur_scene = tree.get_current_scene()
	#tree.get_root().add_child(node)
	#tree.get_root().remove_child(cur_scene)
	#tree.set_current_scene(node)
	
