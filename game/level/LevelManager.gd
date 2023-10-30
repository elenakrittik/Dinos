@icon("res://assets/icons/LevelManager.png")
class_name LevelManager extends Node2D

func _ready():
	var start_pos = Vector2.ZERO

	print(get_children())

	for entity in self.get_child(1).get_child(0).get_child(1).entities:
		if entity.identifier == "Start":
			start_pos = entity.position
			break

	self.find_child("Player").position = start_pos
