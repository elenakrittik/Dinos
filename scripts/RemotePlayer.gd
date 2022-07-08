extends KinematicBody2D;

var velocity: Vector2 = Vector2.ZERO;
var gravity: int = 900;
var hspeed: int = 300;
var vspeed: int = -25;
var jump_speed: int = -300;
var ammo: int = 30;
var ammo_label;
var ammo_reload_frames: int = 0;
var do_reload_ammo: bool = false;
var shoot_frames: int = 0;
var stairs_was_entered: bool = false;
var stairs: Dictionary = {};
var bullet_scene = preload("res://scenes/Dynamic/Bullet.tscn");
var health: int = 100;

func _process(_delta):
	if health == 0:
		queue_free();
