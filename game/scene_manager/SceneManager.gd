class_name SceneManager extends Node

const main_menu = preload("res://game/gui/main_menu.tscn")
var current_child: Node

func _ready():
	self.change_scene(main_menu.instantiate())


func change_scene(new_scene: Node):
	if current_child != null:
		self.remove_child(current_child)

	current_child = new_scene
	self.add_child(new_scene)
