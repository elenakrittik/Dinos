extends Node2D;

var game = load("res://scenes/Game.tscn");
var editor = preload("res://scenes/Editor.tscn");
#var editor_selector = load("res://scenes/EditorSelector.tscn");
var menu = preload("res://scenes/Menu.tscn");
var prompt: FileDialog;

func make_prompt(connect_to: String):
	prompt = FileDialog.new();
	
	prompt.access = FileDialog.ACCESS_FILESYSTEM;
	prompt.current_dir = OS.get_user_data_dir();
	prompt.mode = FileDialog.MODE_OPEN_FILE;
	prompt.add_filter("*.fecl ; Flux Edge Custom Level");
	prompt.connect("file_selected", self, connect_to);
	prompt.resizable = true;
	prompt.rect_position = $ParallaxBackground/ParallaxLayer/Sprite.get_rect().position;
	prompt.rect_size = $ParallaxBackground/ParallaxLayer/Sprite.get_rect().size;
	
	add_child(prompt);
	
	prompt.visible = true;
	prompt.invalidate();

func _on_PlayButton_pressed():
	make_prompt("_on_PlayButton_FileDialog_file_selected");

func _on_EditButton_pressed():
	make_prompt("_on_EditButton_FileDialog_file_selected")

func _on_NewButton_pressed():
	$PlayButton.disabled = true;
	$PlayButton.visible = false;
	$EditButton.disabled = true;
	$EditButton.visible = false;
	$NewButton.disabled = true;
	$NewButton.visible = false;
	$BackButton.disabled = true;
	$BackButton.visible = false;
	
	$LineEdit.visible = true;
	$BackButton2.visible = true;
	$BackButton2.disabled = false;

func _on_PlayButton_FileDialog_file_selected(file: String):
	GlobalVars.xxx_lvl_path = file;
	get_tree().change_scene_to(game);

func _on_EditButton_FileDialog_file_selected(_file: String):
	var file = File.new();
	file.open(_file, file.READ);
	var json = file.get_as_text();
	var data = JSON.parse(json).result;
	file.close();
	
	GlobalVars.xxx_editor_lvldat = data;
	get_tree().change_scene_to(editor);

func _on_LineEdit_text_entered(new_text):
	GlobalVars.xxx_editor_lvlname = new_text;
	get_tree().change_scene_to(editor);

func _on_BackButton_pressed():
	get_tree().change_scene_to(menu);

func _on_BackButton2_pressed():
	get_tree().reload_current_scene();
