extends StaticBody2D;

var particles = preload("res://scenes/Particles/ExplosiveCanBreakParticles.tscn");
var brokentoxcan = preload("res://scenes/Objects/BrokenExplosiveCan.tscn");
var ps_high: Array = [];
var ps_medium: Array = [];
var ps_small: Array = [];

func xxx_process_destroy():
	var instance = brokentoxcan.instance();
	var parts = particles.instance();
	
	parts.position = Vector2.ZERO;
	parts.emitting = true;
	
	instance.position = position;
	instance.add_child(parts);
	instance.name = "brokenexplosivecan_%s" % get_tree().root.get_child(1).get_child(1).get_children().size();
	
	get_tree().root.get_child(1).get_child(1).add_child(instance);
	
	for player in ps_high:
		player.deal_damage(50);
	
	for player in ps_medium:
		player.deal_damage(25);
	
	for player in ps_small:
		player.deal_damage(10);
	
	var camera: Camera2D = get_parent().xxx_player.get_node("Camera2D");
	
	camera.shake(5);
	
	queue_free();

# Small - small damage
# Medium - medium damage
# High - high damage

func _on_small_body_entered(body):
	if body.name == "Player":
		ps_small.append(body);
		ps_medium.erase(body);

func _on_small_body_exited(body):
	if body.name == "Player":
		ps_small.erase(body);


func _on_medium_body_entered(body):
	if body.name == "Player":
		ps_medium.append(body);
		ps_high.erase(body);
		ps_small.erase(body);

func _on_medium_body_exited(body):
	if body.name == "Player":
		ps_medium.erase(body);
		ps_small.append(body);


func _on_big_body_entered(body):
	if body.name == "Player":
		ps_high.append(body);
		ps_medium.erase(body);

func _on_big_body_exited(body):
	if body.name == "Player":
		ps_high.erase(body);
		ps_medium.append(body);

