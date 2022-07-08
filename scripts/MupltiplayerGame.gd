extends Node2D;

var remote_player = preload("res://scenes/Dynamic/RemotePlayer.tscn");
var player_count = 1;
var bullet_scene = preload("res://scenes/Dynamic/Bullet.tscn");

func gather_lvl_data():
	for x in $Level.get_children():
		pass

func _ready():
	get_tree().set_pause(true);
	if GlobalVars.HOST:
		print("HOST")
		var peer = NetworkedMultiplayerENet.new();
		peer.create_server(GlobalVars.SERVER_PORT, GlobalVars.MAX_PLAYERS);
		get_tree().network_peer = peer;
	else:
		print("NOT HOST")
		var peer = NetworkedMultiplayerENet.new();
		peer.create_client(GlobalVars.SERVER_IP, GlobalVars.SERVER_PORT);
		get_tree().network_peer = peer;
	
	get_tree().connect("network_peer_connected", self, "_player_connected");
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected");

func _player_connected(id):
	print("CONNECTED")
	get_tree().set_pause(false);
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc_id(id, "register_player");

func _player_disconnected(id):
	print("DISCONNECTED")
	get_tree().set_pause(true);
	get_tree().set_refuse_new_network_connections(false);
	player_count -= 1;
	remove_child(get_node("RemotePlayer_%s" % id));

remote func register_player():
	print("REGPLAYER")
	var id = get_tree().get_rpc_sender_id();
	var rp = remote_player.instance();
	
	player_count += 1;
	
	rp.position = $Level.get_player_position(player_count);
	rp.name = "RemotePlayer_%s" % id;
	
	add_child(rp);
	
	if player_count == 2:
		get_tree().set_refuse_new_network_connections(true);
		get_tree().set_pause(false);

func do_map_sync():
	rpc("sync_map", $Level);

func dosync():
	rpc_unreliable("sync_player", $Player.position, $Player/AnimatedSprite.animation, $Player.shooted);

remote func sync_player(pos, anim, shoot):
	var id = get_tree().get_rpc_sender_id();
	#print("sync by %s - pos %s - anim %s - shoot %s" % [id, pos, anim, shoot])
	
	get_node("RemotePlayer_%s" % id).position = pos;
	get_node("RemotePlayer_%s" % id).get_node("AnimatedSprite").play(anim);
	
	if shoot > -99:
		var bullet = bullet_scene.instance();
		if anim in ["run_right", "idle_right"]:
			bullet.position.x = get_node("RemotePlayer_%s" % id).get_node("AnimatedSprite").position.x + 20;
		else:
			bullet.position.x = get_node("RemotePlayer_%s" % id).get_node("AnimatedSprite").position.x - 20;
			bullet.get_node("Sprite").flip_h = true;
			bullet.xxx_direction = "left";
		bullet.position.y = get_node("RemotePlayer_%s" % id).get_node("AnimatedSprite").position.y;
		bullet.y_shift = shoot;
		get_node("RemotePlayer_%s" % id).add_child(bullet);
