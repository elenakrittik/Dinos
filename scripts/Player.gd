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
var menu = load("res://scenes/Menu.tscn");
var shooted: int = -99;
var mobile_joystick_texture = preload("res://assets/UI/mobile_joystick_circle.png");
var mobile_joystick_circle_texture = preload("res://assets/UI/mobile_joystick_circle_small.png");
var mobile_button_jump_texture = preload("res://assets/UI/mobile_button_jump.png");
var maporigin: Vector2;
var mobile_joystick: TouchScreenButton;
var mobile_joystick_circle: Sprite;
var mobile_button_jump: TouchScreenButton;
var IS_MOBILE: bool = true;#OS.get_name() == "Android";
var mobile_movement: Vector2;
var mobile_jump: bool = false;

func _ready():
	position = load_level(GlobalVars.xxx_lvl_path);
	maporigin = position;
	
	var font = DynamicFont.new();
	font.font_data = preload("res://assets/akashi.ttf");
	
	for x in $CanvasLayer.get_children():
		x.set("custom_fonts/font", font);
	
	$CanvasLayer/Ammo.bbcode_enabled = true;
	$CanvasLayer/Health.bbcode_enabled = true;
	
	if GlobalVars.HOST:
		get_parent().do_map_sync();
	
	if IS_MOBILE:
		mobile_joystick = TouchScreenButton.new();
		mobile_joystick.name = "MobileJoystick";
		mobile_joystick.normal = mobile_joystick_texture;
		mobile_joystick.position = Vector2(100, 400);
		mobile_joystick.scale = Vector2(0.5, 0.5);
		mobile_joystick.shape = CircleShape2D.new();
		mobile_joystick.shape.radius = 125;
		
		mobile_joystick_circle = Sprite.new();
		mobile_joystick_circle.name = "MobileJoystickCircle";
		mobile_joystick_circle.texture = mobile_joystick_circle_texture;
		mobile_joystick_circle.position = Vector2(100 + 64, 400 + 64);
		mobile_joystick_circle.scale = Vector2(0.25, 0.25);
		
		mobile_button_jump = TouchScreenButton.new();
		mobile_button_jump.name = "MobileButtonJump";
		mobile_button_jump.normal = mobile_button_jump_texture;
		mobile_button_jump.position = Vector2(850, 175);
		mobile_button_jump.scale = Vector2(3, 3);
		
		$CanvasLayer.add_child(mobile_joystick);
		$CanvasLayer.add_child(mobile_joystick_circle);
		$CanvasLayer.add_child(mobile_button_jump);

func _process(_delta):
	if health == 0:
		# warning-ignore:return_value_discarded
		get_tree().change_scene_to(menu);

func _physics_process(delta):
	if get_parent().name == "MultiplayerGame":
		get_parent().dosync();
	shooted = -99;
	if Input.is_action_pressed("shoot"):
		if shoot_frames == 0:
			if ammo > 0:
				ammo -= 1;
				shoot_frames = 7;
				
				var bullet = bullet_scene.instance();
				if $AnimatedSprite.animation in ["run_right", "idle_right"]:
					bullet.position.x = $AnimatedSprite.position.x + 20;
				else:
					bullet.position.x = $AnimatedSprite.position.x - 20;
					bullet.get_node("Sprite").flip_h = true;
					bullet.xxx_direction = "left";
				bullet.position.y = $AnimatedSprite.position.y;
				bullet.randomize_y_shift();
				add_child(bullet);
				
				shooted = bullet.y_shift;
				
				$Camera2D.shake(1, 1);
		else:
			shoot_frames -= 1;
	
	if Input.is_action_just_pressed("reload_ammo"):
		if !do_reload_ammo:
			do_reload_ammo = true;
	
	if do_reload_ammo:
		if ammo_reload_frames == 120:
			ammo = 30;
			ammo_reload_frames = 0;
			do_reload_ammo = false;
		else:
			ammo_reload_frames += 1;
			
			if ammo_reload_frames > 60:
				$CanvasLayer/Ammo.bbcode_text = "Ammo: [color=gray]Reloading.. 1[/color]";
			else:
				$CanvasLayer/Ammo.bbcode_text = "Ammo: [color=gray]Reloading.. 2[/color]";
	
	velocity.x = 0;
	
	if Input.is_action_pressed("left") or (mobile_movement.x > 0.5 and mobile_movement.x != 0):
		velocity.x -= hspeed;
		$AnimatedSprite.play("run_left");
	
	if Input.is_action_pressed("right") or (mobile_movement.x < 0.5 and mobile_movement.x != 0):
		velocity.x += hspeed;
		$AnimatedSprite.play("run_right");
	
	if !(
		Input.is_action_pressed("right")
		or Input.is_action_pressed("left")
		or mobile_movement.x != 0
		or mobile_movement.y != 0
	):
		if $AnimatedSprite.animation == "run_left":
			$AnimatedSprite.play("idle_left");
		
		if $AnimatedSprite.animation == "run_right":
			$AnimatedSprite.play("idle_right");
	
	if Input.is_action_just_pressed("jump") or mobile_jump:
		mobile_jump = false;
		if is_on_floor():
			velocity.y += jump_speed;
	
	if Input.is_action_pressed("up") or mobile_movement.y > 0.5:
		if is_on_stairs():
			velocity.y += vspeed;
	
	velocity.y += gravity * delta;
	velocity = move_and_slide(velocity, Vector2.UP);
	
	var health_color;
	if health > 70:
		health_color = "green";
	elif health > 35 && health <= 70:
		health_color = "yellow";
	elif health > 0 && health <= 35:
		health_color = "red";
	else:
		health_color = "black"
	$CanvasLayer/Health.bbcode_text = "Health: [color=%s]%s[/color]" % [health_color, health];
	
	if !do_reload_ammo:
		var ammo_string;
		if ammo > 20:
			ammo_string = "Ammo: [color=green]%s[/color]" % ammo;
		elif ammo > 10 && ammo <= 20:
			ammo_string = "Ammo: [color=yellow]%s[/color]" % ammo;
		elif ammo > 0 && ammo <= 10:
			ammo_string = "Ammo: [color=red]%s[/color]" % ammo;
		else:
			ammo_string = "Ammo: [color=black]Reload required[/color]";
		$CanvasLayer/Ammo.bbcode_text = ammo_string;

func heal(hp: int):
	if health > 0 && health < 100:
		if health > (100 - hp):
			health = 100;
		else:
			health += hp;
		return true;
	else:
		return false;

func deal_damage(dmg: int):
	if health > 0:
		if health - dmg >= 0:
			health -= dmg;
		else:
			health = 0;

func load_level(path) -> Vector2:
	var lvl = load("res://scenes/Levels/Level.tscn").instance();
	lvl.xxx_player = self;
	lvl.xxx_level_path = path;
	get_parent().call_deferred("add_child", lvl);
	lvl.loader();
	return lvl.xxx_player_startpoint;

func xxx_process_destroy():
	deal_damage(10);

func is_on_stairs():
	for x in stairs.keys():
		if stairs.get(x) == true:
			return true;
		else:
			# warning-ignore:return_value_discarded
			stairs.erase(x);
	return false;

func _input(event):
	if event is InputEventScreenTouch:
		if not event.pressed:
			mobile_movement = Vector2.ZERO;
			print("abcdefg")
	
	if (event is InputEventScreenTouch or event is InputEventScreenDrag) and IS_MOBILE:
		if $CanvasLayer/MobileJoystick.is_pressed():
			# TODO: Prefer dynamic calculation
			var joystick_texture_center: Vector2 = $CanvasLayer/MobileJoystick.position + Vector2(128, 128);
			mobile_movement = (event.position - joystick_texture_center)
			# fuckin' random godot tutorials :rofl:
			mobile_movement.x /= -128;
			mobile_movement.y /= -128;
			
			mobile_joystick_circle.position = event.position;
			print(mobile_movement)
		
		if $CanvasLayer/MobileButtonJump.is_pressed():
			mobile_jump = true;

func _on_area_entered(area):
	if area.name.begins_with("stairs"):
		stairs[area.name] = true;

func _on_area_exited(area):
	if area.name.begins_with("stairs"):
		stairs[area.name] = false;
