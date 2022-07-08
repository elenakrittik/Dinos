extends Node2D;

var select_lvl_script = preload("res://scripts/SelectLevelScript.gd");
var backbutton = preload("res://scenes/Dynamic/BackButton.tscn");

func listdir(path):
	var files: Array = [];
	var dir = Directory.new();
	
	dir.open(path);
	dir.list_dir_begin();
	
	var file_name = dir.get_next();
	
	while file_name != "":
		if !dir.current_is_dir():
			files.append(file_name);
		file_name = dir.get_next();
	
	return files;

func _on_Play_Button_pressed():
	for x in get_children():
		if x is Button:
			if x.name != "BackButton":
				remove_child(x);
	
	var font = DynamicFont.new();
	font.font_data = preload("res://assets/akashi.ttf");
	font.size = 32;
	
	var lvl_id: int = 1;
	var buttons_in_row: int = 0;
	
	for lvl in listdir("res://data/levels/"):
		#var file = File.new();
		#file.open("res://data/levels/%s" % lvl, file.READ);
		#var json = file.get_as_text();
		#var data = JSON.parse(json).result;
		#file.close();
		
		var button: Button = Button.new();
		
		button.set_position(get_button_position(buttons_in_row));
		button.text = String(lvl_id);
		button.flat = true;
		button.set_script(select_lvl_script);
		button.xxx_lvl_path = "res://data/levels/%s.json" % lvl_id;
		button.connect("pressed", button, "_on_button_pressed");
		button.set("custom_fonts/font", font);
		
		add_child(button);
		
		lvl_id += 1;
		buttons_in_row += 1;
		
		if buttons_in_row == 4:
			buttons_in_row = 0;
	
	$BackButton.visible = true;

func get_button_position(bir: int, add: bool = true):
	var base = $Camera2D/Sprite.get_rect();
	
	var y: int = base.position.y + (((bir + 1) / 10) * 6);
	
	while (bir / 10) >= 1:
		bir -= 10;
	var x: int = base.position.x + ((bir + 1) * 32);
	
	if add:
		y += 64;
	
	return Vector2(x, y);

func _on_About_pressed():
	get_tree().change_scene("res://scenes/MenuAbout.tscn");

func _on_Back_pressed():
	get_tree().change_scene("res://scenes/Menu.tscn");

func _on_EditorButton_pressed():
	get_tree().change_scene("res://scenes/EditorSelector.tscn");

func _on_MultiplayerButton_pressed():
	get_tree().change_scene("res://scenes/MenuMultiplayer.tscn");
