extends Node;

var game = preload("res://scenes/Game.tscn");
var xxx_lvl_path: String;

func _on_button_pressed():
	GlobalVars.xxx_lvl_path = xxx_lvl_path;
	get_tree().change_scene_to(game);
