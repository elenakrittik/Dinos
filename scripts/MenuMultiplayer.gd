extends Node2D;

var prompt: FileDialog;
var bbstate: int = 1; # 1 - main, 2 - host or connect
var menu = load("res://scenes/Menu.tscn");

func make_prompt(ct):
	prompt = FileDialog.new();
	
	prompt.access = FileDialog.ACCESS_FILESYSTEM;
	prompt.current_dir = OS.get_user_data_dir();
	prompt.mode = FileDialog.MODE_OPEN_FILE;
	prompt.add_filter("*.fecl ; Flux Edge Custom Level");
	prompt.connect("file_selected", self, ct);
	prompt.resizable = true;
	prompt.rect_position = $Camera2D/Sprite.get_rect().position;
	prompt.rect_size = $Camera2D/Sprite.get_rect().size;
	
	add_child(prompt);
	
	prompt.visible = true;
	prompt.invalidate();

func _on_ConnectButton_pressed():
	bbstate = 2;
	$HostButton.disabled = true;
	$HostButton.visible = false;
	
	$ConnectButton.disabled = true;
	$ConnectButton.visible = false;
	
	$IPAddrInput.visible = true;

func _on_HostButton_pressed():
	make_prompt("_on_host_lvl_selected");

func _on_IPAddrInput_text_entered(new_text):
	GlobalVars.SERVER_IP = new_text;
	make_prompt("_on_nonhost_lvl_selected");
	
func _on_host_lvl_selected(file):
	GlobalVars.HOST = true;
	GlobalVars.xxx_lvl_path = file;
	get_tree().change_scene("res://scenes/MultiplayerGame.tscn");

func _on_nonhost_lvl_selected(file):
	GlobalVars.xxx_lvl_path = file;
	get_tree().change_scene("res://scenes/MultiplayerGame.tscn");

func _on_BackButton_pressed():
	if bbstate == 1:
		get_tree().change_scene_to(menu);
	else:
		get_tree().reload_current_scene();
