extends Node2D;

var i: int = 0;
var save_path: String = "";

var current_tile_line: Line2D;
var current_tile: String;
var selected_tile: String = "";
var tiles: Dictionary = {};

var allow_put: bool = true;

var lvlname: String;

#onready var layout: Sprite = $ViewCenter/Camera2D/CanvasLayer/Layout;
#var panel_rect: Rect2 = Rect2(Vector2(0, 480), Vector2(layout.get_rect().size.x, layout.size.y));

var earthtex = preload("res://assets/Objects/Earth.png");
var earth1tex = preload("res://assets/Objects/Earth1.png");
var explosivecantex = preload("res://assets/Objects/ExplosiveCan.png");
var explosivecanbrokentex = preload("res://assets/Objects/ExplosiveCanBroken.png");
var stairstex = preload("res://assets/Objects/Stairs.png");
var toxiccantex = preload("res://assets/Objects/ToxicCan.png");
var toxiccanbrokentex = preload("res://assets/Objects/ToxicCanBroken.png");
var spawnpointtex = preload("res://assets/Objects/Spawnpoint.png");
var p2spawnpointtex = preload("res://assets/Objects/Spawnpoint2.png");
var autosave: Timer;
var menu = preload("res://scenes/Menu.tscn");

func _ready():
	if GlobalVars.xxx_editor_lvldat:
		var lvldat: Dictionary = GlobalVars.xxx_editor_lvldat;
		
		lvlname = lvldat['name'];
		
		for obj in lvldat['objects']:
			place_block(obj, false);
		
		var dd = {
			"type": "spawnpoint",
			"cell": [lvldat['startpoint']['x'], lvldat['startpoint']['y']]
		}
		place_block(dd, false)
		
		if lvldat.get("p2spawnpoint"):
			dd = {
				"type": "p2spawnpoint",
				"cell": [lvldat['p2startpoint']['x'], lvldat['p2startpoint']['y']]
			}
			place_block(dd, false)
	
	autosave = Timer.new();
	autosave.wait_time = 60.0;
	autosave.autostart = true;
	autosave.connect("timeout", self, "_on_SaveButton_pressed");
	add_child(autosave);
	
	var x: int = 0;
	
	while x < 32 * 256: # 256 tiles - map width
		var line: Line2D = Line2D.new();
		line.add_point(Vector2(x, 0));
		line.add_point(Vector2(x, 32 * 128));
		line.width = 1;
		line.z_index = -3;
		line.name = "line_x_%s" % x;
		add_child(line);
		
		x += 32;
	
	var y: int = 0;
	
	while y < 32 * 128: # 128 tiles - map height
		var line: Line2D = Line2D.new();
		line.add_point(Vector2(0, y));
		line.add_point(Vector2(32 * 256, y));
		line.width = 1;
		line.z_index = -3;
		line.name = "line_y_%s" % y;
		add_child(line);
		
		y += 32;

func hex(integer: int) -> String:
	var s: String = "%x" % integer;
	
	if integer < 16:
		s = "0" + s;
	
	return s

func _process(_delta):
	
	if i > 0:
		i -= 1;
		var txt: String = "[color=#%sFFFFFF]Level saved to %s[/color]" % [hex(i).to_upper(), save_path];
		$ViewCenter/Camera2D/CanvasLayer/SavedLabel.bbcode_text = txt;
	$ViewCenter/Camera2D/CanvasLayer/PositionLabel.text = "(%s, %s)" % [round($ViewCenter.position.x - 512), round($ViewCenter.position.y - 300)];
	if (
		Input.is_action_pressed("editor_placetile") &&
		allow_put
	):
		
		place_block({"type": selected_tile});
	
	if Input.is_action_just_pressed("editor_movedown") && !Input.is_action_just_pressed("editor_savelevel"):
		if current_tile != "":
			$Objects.get_node(current_tile).position.y += 32;
			current_tile_line.clear_points();
			current_tile_line.add_point(Vector2($Objects.get_node(current_tile).position.x - 16, $Objects.get_node(current_tile).position.y - 16));
			current_tile_line.add_point(Vector2($Objects.get_node(current_tile).position.x - 16, $Objects.get_node(current_tile).position.y + 16));
			current_tile_line.add_point(Vector2($Objects.get_node(current_tile).position.x + 16, $Objects.get_node(current_tile).position.y + 16));
			current_tile_line.add_point(Vector2($Objects.get_node(current_tile).position.x + 16, $Objects.get_node(current_tile).position.y - 16));
			current_tile_line.add_point(Vector2($Objects.get_node(current_tile).position.x - 16, $Objects.get_node(current_tile).position.y - 16));
	
	if Input.is_action_just_pressed("editor_moveup"):
		if current_tile != "":
			if $Objects.get_node(current_tile).position.y > 16:
				$Objects.get_node(current_tile).position.y -= 32;
				current_tile_line.clear_points();
				current_tile_line.add_point(Vector2($Objects.get_node(current_tile).position.x - 16, $Objects.get_node(current_tile).position.y - 16));
				current_tile_line.add_point(Vector2($Objects.get_node(current_tile).position.x - 16, $Objects.get_node(current_tile).position.y + 16));
				current_tile_line.add_point(Vector2($Objects.get_node(current_tile).position.x + 16, $Objects.get_node(current_tile).position.y + 16));
				current_tile_line.add_point(Vector2($Objects.get_node(current_tile).position.x + 16, $Objects.get_node(current_tile).position.y - 16));
				current_tile_line.add_point(Vector2($Objects.get_node(current_tile).position.x - 16, $Objects.get_node(current_tile).position.y - 16));
	
	if Input.is_action_just_pressed("editor_moveright"):
		if current_tile != "":
			$Objects.get_node(current_tile).position.x += 32;
			current_tile_line.clear_points();
			current_tile_line.add_point(Vector2($Objects.get_node(current_tile).position.x - 16, $Objects.get_node(current_tile).position.y - 16));
			current_tile_line.add_point(Vector2($Objects.get_node(current_tile).position.x - 16, $Objects.get_node(current_tile).position.y + 16));
			current_tile_line.add_point(Vector2($Objects.get_node(current_tile).position.x + 16, $Objects.get_node(current_tile).position.y + 16));
			current_tile_line.add_point(Vector2($Objects.get_node(current_tile).position.x + 16, $Objects.get_node(current_tile).position.y - 16));
			current_tile_line.add_point(Vector2($Objects.get_node(current_tile).position.x - 16, $Objects.get_node(current_tile).position.y - 16));
	
	if Input.is_action_just_pressed("editor_moveleft"):
		if current_tile != "":
			if $Objects.get_node(current_tile).position.x > 16:
				$Objects.get_node(current_tile).position.x -= 32;
				current_tile_line.clear_points();
				current_tile_line.add_point(Vector2($Objects.get_node(current_tile).position.x - 16, $Objects.get_node(current_tile).position.y - 16));
				current_tile_line.add_point(Vector2($Objects.get_node(current_tile).position.x - 16, $Objects.get_node(current_tile).position.y + 16));
				current_tile_line.add_point(Vector2($Objects.get_node(current_tile).position.x + 16, $Objects.get_node(current_tile).position.y + 16));
				current_tile_line.add_point(Vector2($Objects.get_node(current_tile).position.x + 16, $Objects.get_node(current_tile).position.y - 16));
				current_tile_line.add_point(Vector2($Objects.get_node(current_tile).position.x - 16, $Objects.get_node(current_tile).position.y - 16));
	
	if Input.is_action_just_pressed("editor_deletetile"):
		_on_DeleteButton_pressed();
	
	if Input.is_action_just_pressed("editor_savelevel"):
		_on_SaveButton_pressed();
	
	if Input.is_action_just_pressed("editor_exit"):
		_on_SaveButton_pressed();
		get_tree().change_scene_to(menu);
	
	allow_put = true;

func _input(event):
	if (
		event is InputEventMouseMotion &&
		Input.is_action_pressed("editor_movecamera")
	):
		if (($ViewCenter.position.x + event.relative.x) > 512) or (event.relative.x > 0):
			$ViewCenter.position.x += event.relative.x;
		
		if (($ViewCenter.position.y + event.relative.y) > 300) or (event.relative.y > 0):
			$ViewCenter.position.y += event.relative.y;

func _on_EarthButton_pressed():
	selected_tile = "earth";
	allow_put = false;

func _on_Earth1Button_pressed():
	selected_tile = "earth1";
	allow_put = false;

func _on_ExplosiveCanButton_pressed():
	selected_tile = "explosivecan";
	allow_put = false;

func _on_ExplosiveCanBrokenButton_pressed():
	selected_tile = "explosivecanbroken";
	allow_put = false;

func _on_SpawnpointButton_pressed():
	selected_tile = "spawnpoint";
	allow_put = false;

func _on_StairsButton_pressed():
	selected_tile = "stairs";
	allow_put = false;

func _on_ToxicCanButton_pressed():
	selected_tile = "toxiccan";
	allow_put = false;

func _on_ToxicCanBrokenButton_pressed():
	selected_tile = "toxiccanbroken";
	allow_put = false;

func _on_SaveButton_pressed():
	allow_put = false;
	var data: Dictionary = {
		"name": "",
		"objects": []
	};
	
	if lvlname == "":
		data['name'] = GlobalVars.xxx_editor_lvlname;
	else:
		data['name'] = lvlname;
	
	for obj in $Objects.get_children():
		var type: String;
		var do_continue: bool = false;
		
		match obj.texture:
			earthtex:
				type = "earth";
			earth1tex:
				type = "earth1";
			explosivecantex:
				type = "explosivecan";
			explosivecanbrokentex:
				type = "explosivecanbroken";
			stairstex:
				type = "stairs";
			toxiccantex:
				type = "toxiccan";
			toxiccanbrokentex:
				type = "toxiccanbroken";
			spawnpointtex:
				data['startpoint'] = {
					"x": (obj.position.x + 16) / 32,
					"y": (obj.position.y + 16) / 32
				};
				do_continue = true;
			p2spawnpointtex:
				data['p2startpoint'] = {
					"x": (obj.position.x + 16) / 32,
					"y": (obj.position.y + 16) / 32
				}
				do_continue = true;
			_:
				do_continue = true;
		
		if do_continue:
			continue;
		
		data['objects'].append({
			"type": type,
			"cell": [(obj.position.x + 16) / 32, (obj.position.y + 16) / 32]
		});
	
	# Ensure the CustomLevels directory exists
	var dir = Directory.new();
	dir.open("user://");
	dir.make_dir("CustomLevels");
	dir.open("res://");
	
	var file = File.new();
	file.open("user://CustomLevels/%s.fecl" % data['name'], File.WRITE);
	file.store_line(to_json(data));
	
	$ViewCenter/Camera2D/CanvasLayer/SavedLabel.bbcode_text = "[color=#FFFFFFFF]Level saved to %s[/color]" % file.get_path_absolute();
	
	i = 255;
	save_path = file.get_path_absolute();
	
	file.close();


func _on_DeleteButton_pressed():
	allow_put = false;
	if current_tile != "":
		var tl = $Objects.get_node(current_tile);
		
		tiles.erase(tl.position);
		$Objects.remove_child(tl);
		tl.queue_free();
		
		remove_child(get_node(current_tile_line.name));
		current_tile_line.queue_free();
		current_tile_line = null;
		
		current_tile = "";

func place_block(obj: Dictionary, calc: bool = true):
	if calc:
		var tile: Sprite = Sprite.new();
		tile.position = Vector2(
			((floor(get_viewport().get_mouse_position().x / 32) + 1) * 32) - 16,
			((floor(get_viewport().get_mouse_position().y / 32) + 1) * 32) - 16
		);
		
		if $ViewCenter.position.x != 512:
			tile.position.x += 32 * (round(($ViewCenter.position.x - 512) / 32));
		
		if $ViewCenter.position.y != 300:
			tile.position.y += 32 * (round(($ViewCenter.position.y - 300) / 32));
		
		if tiles.get(tile.position):
			current_tile = tiles.get(tile.position).name;
			if current_tile_line:
				current_tile_line.clear_points();
				current_tile_line.add_point(Vector2(tile.position.x - 16, tile.position.y - 16));
				current_tile_line.add_point(Vector2(tile.position.x - 16, tile.position.y + 16));
				current_tile_line.add_point(Vector2(tile.position.x + 16, tile.position.y + 16));
				current_tile_line.add_point(Vector2(tile.position.x + 16, tile.position.y - 16));
				current_tile_line.add_point(Vector2(tile.position.x - 16, tile.position.y - 16));
			else:
				current_tile_line = Line2D.new();
				current_tile_line.add_point(Vector2(tile.position.x - 16, tile.position.y - 16));
				current_tile_line.add_point(Vector2(tile.position.x - 16, tile.position.y + 16));
				current_tile_line.add_point(Vector2(tile.position.x + 16, tile.position.y + 16));
				current_tile_line.add_point(Vector2(tile.position.x + 16, tile.position.y - 16));
				current_tile_line.add_point(Vector2(tile.position.x - 16, tile.position.y - 16));
				current_tile_line.z_index = -1;
				current_tile_line.default_color = Color(255, 211, 0);
				current_tile_line.width = 2;
				add_child(current_tile_line);
			return;
		
		match obj['type']:
			"earth":
				tile.texture = earthtex;
				tile.name = "earth_%s" % tiles.size();
			"earth1":
				tile.texture = earth1tex;
				tile.name = "earth1_%s" % tiles.size();
			"explosivecan":
				tile.texture = explosivecantex;
				tile.name = "explosivecan_%s" % tiles.size();
			"explosivecanbroken":
				tile.texture = explosivecanbrokentex;
				tile.name = "explosivecanbroken_%s" % tiles.size();
			"stairs":
				tile.texture = stairstex;
				tile.name = "stairs_%s" % tiles.size();
			"toxiccan":
				tile.texture = toxiccantex;
				tile.name = "toxiccan_%s" % tiles.size();
			"toxiccanbroken":
				tile.texture = toxiccanbrokentex;
				tile.name = "toxiccanbroken_%s" % tiles.size();
			"spawnpoint":
				tile.texture = spawnpointtex;
				tile.name = "spawnpoint_%s" % tiles.size();
			"p2spawnpoint":
				tile.texture = p2spawnpointtex;
				tile.name = "p2spawnpoint_%s" % tiles.size();
			_:
				return;
		
		print(tile.name)
		tile.z_index = -2;
		
		$Objects.add_child(tile);
		tiles[tile.position] = tile;
		current_tile = tile.name;
		
		if current_tile_line:
			current_tile_line.clear_points();
			current_tile_line.add_point(Vector2(tile.position.x - 16, tile.position.y - 16));
			current_tile_line.add_point(Vector2(tile.position.x - 16, tile.position.y + 16));
			current_tile_line.add_point(Vector2(tile.position.x + 16, tile.position.y + 16));
			current_tile_line.add_point(Vector2(tile.position.x + 16, tile.position.y - 16));
			current_tile_line.add_point(Vector2(tile.position.x - 16, tile.position.y - 16));
		else:
			current_tile_line = Line2D.new();
			current_tile_line.add_point(Vector2(tile.position.x - 16, tile.position.y - 16));
			current_tile_line.add_point(Vector2(tile.position.x - 16, tile.position.y + 16));
			current_tile_line.add_point(Vector2(tile.position.x + 16, tile.position.y + 16));
			current_tile_line.add_point(Vector2(tile.position.x + 16, tile.position.y - 16));
			current_tile_line.add_point(Vector2(tile.position.x - 16, tile.position.y - 16));
			current_tile_line.z_index = -1;
			current_tile_line.default_color = Color(255, 211, 0);
			current_tile_line.width = 2;
			add_child(current_tile_line);
	else:
		var tile: Sprite = Sprite.new();
		tile.position = Vector2(
			(obj['cell'][0] * 32) - 16,
			(obj['cell'][1] * 32) - 16
		);
		
		#if $ViewCenter.position.x != 512:
		#	tile.position.x += 32 * (round(($ViewCenter.position.x - 512) / 32));
		
		#if $ViewCenter.position.y != 300:
		#	tile.position.y += 32 * (round(($ViewCenter.position.y - 300) / 32));
		
		#if tiles.get(tile.position):
		#	current_tile = tiles.get(tile.position).name;
		#	if current_tile_line:
		#		current_tile_line.clear_points();
		#		current_tile_line.add_point(Vector2(tile.position.x - 16, tile.position.y - 16));
		#		current_tile_line.add_point(Vector2(tile.position.x - 16, tile.position.y + 16));
		#		current_tile_line.add_point(Vector2(tile.position.x + 16, tile.position.y + 16));
		#		current_tile_line.add_point(Vector2(tile.position.x + 16, tile.position.y - 16));
		#		current_tile_line.add_point(Vector2(tile.position.x - 16, tile.position.y - 16));
		#	else:
		#		current_tile_line = Line2D.new();
		#		current_tile_line.add_point(Vector2(tile.position.x - 16, tile.position.y - 16));
		#		current_tile_line.add_point(Vector2(tile.position.x - 16, tile.position.y + 16));
		#		current_tile_line.add_point(Vector2(tile.position.x + 16, tile.position.y + 16));
		#		current_tile_line.add_point(Vector2(tile.position.x + 16, tile.position.y - 16));
		#		current_tile_line.add_point(Vector2(tile.position.x - 16, tile.position.y - 16));
		#		current_tile_line.z_index = -1;
		#		current_tile_line.default_color = Color(255, 211, 0);
		#		current_tile_line.width = 2;
		#		add_child(current_tile_line);
		#	return;
		
		match obj['type']:
			"earth":
				tile.texture = earthtex;
				tile.name = "earth_%s";
			"earth1":
				tile.texture = earth1tex;
				tile.name = "earth1_%s";
			"explosivecan":
				tile.texture = explosivecantex;
				tile.name = "explosivecan_%s";
			"explosivecanbroken":
				tile.texture = explosivecanbrokentex;
				tile.name = "explosivecanbroken_%s";
			"stairs":
				tile.texture = stairstex;
				tile.name = "stairs_%s";
			"toxiccan":
				tile.texture = toxiccantex;
				tile.name = "toxiccan_%s";
			"toxiccanbroken":
				tile.texture = toxiccanbrokentex;
				tile.name = "toxiccanbroken_%s";
			"spawnpoint":
				tile.texture = spawnpointtex;
				tile.name = "spawnpoint_%s";
			"spawnpoint2":
				tile.texture = p2spawnpointtex;
				tile.name = "p2spawnpoint_%s";
			_:
				return;
		
		tile.name = tile.name % tiles.size();
		tile.z_index = -2;
		
		$Objects.add_child(tile);
		tiles[tile.position] = tile;
		#current_tile = tile.name;
		
		#if current_tile_line:
		#	current_tile_line.clear_points();
		#	current_tile_line.add_point(Vector2(tile.position.x - 16, tile.position.y - 16));
		#	current_tile_line.add_point(Vector2(tile.position.x - 16, tile.position.y + 16));
		#	current_tile_line.add_point(Vector2(tile.position.x + 16, tile.position.y + 16));
		#	current_tile_line.add_point(Vector2(tile.position.x + 16, tile.position.y - 16));
		#	current_tile_line.add_point(Vector2(tile.position.x - 16, tile.position.y - 16));
		#else:
		#	current_tile_line = Line2D.new();
		#	current_tile_line.add_point(Vector2(tile.position.x - 16, tile.position.y - 16));
		#	current_tile_line.add_point(Vector2(tile.position.x - 16, tile.position.y + 16));
		#	current_tile_line.add_point(Vector2(tile.position.x + 16, tile.position.y + 16));
		#	current_tile_line.add_point(Vector2(tile.position.x + 16, tile.position.y - 16));
		#	current_tile_line.add_point(Vector2(tile.position.x - 16, tile.position.y - 16));
		#	current_tile_line.z_index = -1;
		#	current_tile_line.default_color = Color(255, 211, 0);
		#	current_tile_line.width = 2;
		#	add_child(current_tile_line);


func _on_Spawnpoint2Button_pressed():
	selected_tile = "p2spawnpoint";
	allow_put = false;
