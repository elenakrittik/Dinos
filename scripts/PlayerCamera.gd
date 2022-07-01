extends Camera2D;

var shake_power: int = 0;
var shake_count: int = 5;
var shakes: int = shake_count;

func shake(power: int, shakecount: int = 5):
	shake_power = power;
	shake_count = shakecount;
	shakes = 0;
	
func _process(_delta):
	if shakes < shake_count:
		set_offset(Vector2(rand_range(-1.0, 1.0) * shake_power, rand_range(-1.0, 1.0) * shake_power))
		shakes += 1;
	else:
		set_offset(Vector2.ZERO);
