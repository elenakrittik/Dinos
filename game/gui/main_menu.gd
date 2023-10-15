extends Node2D

const level1 = preload("res://assets/levels/level1.tscn")
const player = preload("res://game/player/Player.tscn")
const level_container = preload("res://game/level/Level.tscn")

func _on_button_pressed():
	var lvl = level1.instantiate()
	var cntnr = level_container.instantiate()
	cntnr.lvl = lvl
	cntnr.add_child(lvl)

	(get_tree().root.get_child(0) as SceneManager).change_scene(cntnr)
