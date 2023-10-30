extends Node2D

const level1 = preload("res://assets/levels/level1.tscn")
const player = preload("res://game/player/Player.tscn")
const level_mgr = preload("res://game/level/LevelManager.tscn")

func _on_button_pressed():
	var lvl = level1.instantiate()
	var mgr = level_mgr.instantiate()
	mgr.add_child(lvl)

	(get_tree().root.get_child(0) as SceneManager).change_scene(mgr)
