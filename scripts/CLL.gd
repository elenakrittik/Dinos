extends Node2D;

var earth = preload("res://scenes/Objects/Earth.tscn");
var earth1 = preload("res://scenes/Objects/Earth1.tscn");
var toxiccan = preload("res://scenes/Objects/ToxicCan.tscn");
var stairs = preload("res://scenes/Objects/Stairs.tscn");
var aidkit = preload("res://scenes/Objects/AidKit.tscn");
var explosivecan = preload("res://scenes/Objects/ExplosiveCan.tscn");
var brokenexplosivecan = preload("res://scenes/Objects/BrokenExplosiveCan.tscn");
var brokentoxiccan = preload("res://scenes/Objects/BrokenToxicCan.tscn");

var xxx_player_startpoint: Vector2 = Vector2(2 * 32, 5 * 32);
var xxx_player: KinematicBody2D;
#var xxx_level_path: String;

func load_level(idx) -> Vector2:
	var lvl = load("res://scenes/Levels/Level.tscn").instance();
	lvl.xxx_player = self;
	lvl.xxx_level_id = idx;
	get_parent().call_deferred("add_child", lvl);
	return lvl.xxx_player_startpoint;

func _load_level(path: String):
	var level = Node2D.new();
	
	var file = File.new();
	file.open(path, file.READ);
	var json = file.get_as_text();
	var data = JSON.parse(json).result;
	file.close();
	
	xxx_player_startpoint = Vector2(data['startpoint']['x'] * 32, data['startpoint']['y'] * 32);
	
	var count: int = 0;
	
	for obj in data['objects']:
		var block;
		
		if obj['type'] == 'earth':
			block = earth.instance();
		
		elif obj['type'] == "earth1":
			block = earth1.instance();
		
		elif obj['type'] == "aidkit":
			block = aidkit.instance();
		
		elif obj['type'] == "toxiccan":
			block = toxiccan.instance();
		
		elif obj['type'] == "stairs":
			block = stairs.instance();
		
		elif obj['type'] == "explosivecan":
			block = explosivecan.instance();
		
		elif obj['type'] == "explosivecanbroken":
			block = brokenexplosivecan.instance();
		
		elif obj['type'] == "toxiccanbroken":
			block = brokentoxiccan.instance();
		
		else:
			print("Invalid object encountered: %s. Skipping.." % obj)
			continue; # skip invalid blocks
		
		var x = obj['cell'][0] * 32;
		var y = obj['cell'][1] * 32;
		block.position = Vector2(x, y);
		
		block.name = "%s_%s" % [obj['type'], count]
		
		level.add_child(block);
		count += 1;
