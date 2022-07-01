extends KinematicBody2D;

var x_speed: int = 10;
var y_shift: int = 0;
var velocity: Vector2 = Vector2.ZERO;
var xxx_direction: String = "right";
#var toxic_can_broken_tex = preload("res://assets/ToxicCanBroken.png");

func randomize_y_shift():
	var rng = RandomNumberGenerator.new();
	rng.randomize();
	y_shift = rng.randi_range(-2, 2);

func _physics_process(_delta):
	velocity = Vector2.ZERO;
	
	if xxx_direction == "right":
		velocity.x += x_speed;
	else:
		velocity.x -= x_speed;
	velocity.y += y_shift;
	
	var collision = move_and_collide(velocity);
	
	if (collision):
		if collision.collider.has_method("xxx_process_destroy"):
			collision.collider.xxx_process_destroy()
		queue_free();
