extends Node

const IP_ADDRESS = "thisissodumb.herokuapp.com"
const PORT = 443
var server_url = "wss://%s:%d/ws/" % [IP_ADDRESS, PORT]

#const IP_ADDRESS = "127.0.0.1"
#const PORT = 11111
#var server_url = "ws://%s:%d" % [IP_ADDRESS, PORT]

var network = WebSocketClient.new()

signal spawn_npc_m(pos)
signal hit_npc_m(npc_sprite_name, bullet_name)
signal move_emac_m(vim_motion)
signal send_bullet_emac_m(lister)
signal turn_npc_m(npc_name, angle, wait_time)

func _ready():
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	connect_to_server()

func _on_connection_failed():
	# try connecting again
	print("connection failed, i will try again")
	yield(get_tree().create_timer(0.5), "timeout")
	connect_to_server()


func _on_connection_succeeded():
	print("connection suceed :)")
	rpc_id(1, "rpc_test", get_tree().get_network_unique_id())

func connect_to_server():
	network.connect_to_url(server_url, PoolStringArray(), true);
	get_tree().set_network_peer(network)

func serv_start_game(room_id):
	rpc_id(1, "start_game", room_id)

remote func add_player(player_id, is_me, room_id):
	Glob.PLAYER_DICT[player_id] = 1
	Glob.ROOM_ID = room_id
	if is_me:
		Glob.PLAYER_ID = player_id
	print("add p ", Glob.PLAYER_DICT)

remote func remove_player(player_id):
	Glob.PLAYER_DICT.erase(player_id)
	print("rem p ", Glob.PLAYER_DICT)

remote func make_host():
	print("you are host")
	Glob.TEAM = "vim"
	get_node("/root/MainMenu/PlayButton").show()
#	$PlayButton.show()
	
	
remote func make_puppet():
	print("you are puppet")
	Glob.TEAM = "emacs"
	
remote func reset_role(new_room_id):
	print("you are no longer host or puppet")
	Glob.TEAM = "NONE"
	
	if get_node_or_null("/root/Main"):
		get_node("/root/Main").DISCONNECT = true
		get_tree().call_group("stopper", "freeze")
		get_node("/root/Main/GameTimer").stop()
		
		get_node("/root/Main/PlayAgainButton").hide()
		
		get_node("/root/Main/WinCenterContainer/WinLabel").text = "Opponent forfeit, Vim Wins!"
		get_node("/root/Main/MainMenuButton").show()
		
		rpc_id(1, "in_game_dc", Glob.PLAYER_ID)
		
#	Glob.new_room_id = new_room_id
	
	var play_button = get_node_or_null("/root/MainMenu/PlayButton")
	if play_button:
		play_button.hide()
		
func peer_change_room_dc_serv(player_id):
	rpc_id(1, "peer_change_room_dc", player_id)
		

func _deferred_change_scene(new_scene_path):
	var root = get_tree().get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
	set_process(false)
	current_scene.queue_free()
	current_scene = load(new_scene_path).instance()
	root.add_child(current_scene)
	get_tree().set_current_scene(current_scene)

remote func start_game():
#	GAME_SC.instance()
	print('started game')
	call_deferred("_deferred_change_scene", 'res://Main.tscn')
	
func serv_restart_game(room_id):
	rpc_id(1, "restart_game", room_id)

remote func restart_game():
	get_node("/root/Main").get_tree().reload_current_scene()
	
func serv_spawn_npc(room_id):
	var pos_arr = []
	for i in range(5):
		var pos = Vector2(Glob.RNG.randi_range(275, 750), Glob.RNG.randi_range(125, 425))
		pos_arr.push_back(pos)

	rpc_id(1, "spawn_npc", pos_arr, room_id)

remote func spawn_npc(pos):
	print("suppsoed to be spawning?")
	emit_signal("spawn_npc_m", pos)
	
func serv_hit_npc(npc_sprite_name, bullet_name, player_name, room_id):
	rpc_id(1, "hit_npc", npc_sprite_name, bullet_name, player_name, room_id)


remote func hit_npc(npc_sprite_name, bullet_name):
	emit_signal("hit_npc_m", npc_sprite_name, bullet_name)

func serv_move_player(vim_motion, player_id, room_id):
	rpc_id(1, "move_player", vim_motion, player_id, room_id)

remote func move_player(vim_motion):
	emit_signal("move_emac_m", vim_motion)
	
func serv_send_bullet(lister, player_id, room_id):
	rpc_id(1, "send_bullet", lister, player_id, room_id)

remote func send_bullet(lister):
	emit_signal("send_bullet_emac_m", lister)
	


func serv_turn_npc(npc_name, room_id):
#	print("serv turn npc called ", npc_name)
	var angle = Glob.RNG.randi_range(-180, 180)
	var wait_time = Glob.RNG.randi_range(1, 5)
	rpc_id(1, "turn_npc", npc_name, angle, wait_time, room_id)
	

remote func turn_npc(npc_name, angle, wait_time):
	emit_signal("turn_npc_m", npc_name, angle, wait_time)
