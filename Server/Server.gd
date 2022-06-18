extends Node

const PORT = 11111
var network = WebSocketServer.new();
onready var root_node = get_tree().get_root()
var CURR_ROOM = 1

var PLAYER_DICT = {}


func _ready():
	VisualServer.set_default_clear_color(Color(1,0,0,1.0))
	start_server()
	add_room()

func add_room():
	print("adding room")
	var room = Node.new()
	$RoomList.add_child(room)
	room.name = CURR_ROOM as String
	CURR_ROOM += 1

func find_room(ROOM_NUM):
#	print("trying to find ", ROOM_NUM, " || children: ", $RoomList.get_children())
	for r in $RoomList.get_children():
#		print("room name ", ROOM_NUM, " r name ", r.name, " || ", int(r.name) == ROOM_NUM)
		if int(r.name) == ROOM_NUM:
			return r

func _process(_delta):
	if network.is_listening():
		# check for incoming connections
		network.poll()


func start_server():
	network.listen(PORT, PoolStringArray(), true);
	get_tree().set_network_peer(network)
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")


func _peer_connected(player_id):
	if find_room(CURR_ROOM - 1).get_children().size() == 2:
		add_room()
		
	var select_room = CURR_ROOM - 1
	print("player connect: ", player_id, " || ", select_room)
		
	PLAYER_DICT[player_id] = select_room

	var label = Label.new()
	var curr_room_node = get_node("RoomList/" + (select_room) as String)
	
	# only add again if they are new
#	if get_childe(curr_room_node, player_id):
#		pass
#	else:
	curr_room_node.add_child(label)
	label.set_name(player_id as String)

	var player_list = player_list(select_room)
	for c in player_list:
		# load all for new player
		if c == player_id:
			for player in player_list:
				 rpc_id(player_id, "add_player", player, player_id == player, select_room)
		
		# only load new player
		else:	
			rpc_id(c, "add_player", player_id, false, select_room)
		
	if player_list.size() == 2:
		rpc_id(player_list[0], "make_host")
		rpc_id(player_list[1], "make_puppet")
	
#	pass

func player_list(ROOM_ID):
	var player_list = []
	for p in find_room(ROOM_ID).get_children():
		player_list.push_back(int(p.name))
	
	return player_list

func get_childe(parent, player_id):
	for c in parent.get_children():
		if (player_id as String) == c.name:
			return c
#	for r in $RoomList.get_children():
#		if int(r.name) == ROOM_NUM:
#			return r

	

func _peer_disconnected(player_left_id):
	print("player disconnect: ", player_left_id)
#	delete_child($PlayerList, player_id)
	
	var room = find_room(PLAYER_DICT[player_left_id])
	delete_child(room, get_childe(room, player_left_id))

	for c in player_list(PLAYER_DICT[player_left_id]):
		rpc_id(c, "remove_player", player_left_id)
	
	if room.get_children().size() != 0:
		var player_alive_id = int(room.get_children()[0].name)
		rpc_id(player_alive_id, "reset_role", room)
#		_peer_disconnected(player_alive_id)
		
		PLAYER_DICT.erase(player_left_id)

remote func in_game_dc(player_alive_id):
	_peer_disconnected(player_alive_id)
	
#	var select_room = CURR_ROOM
#	var curr_room_node = get_node("RoomList/" + select_room as String)
#
#	var label = Label.new()
##	var curr_room_node = get_node("RoomList/" + (select_room) as String)
#
#	curr_room_node.add_child(label)
#	label.set_name(player_id as String)
	
#	PLAYER_DICT[player_id] = select_room
	
#	var player_list = player_list(PLAYER_DICT[player_id])

remote func spin_man(deg, room_id):
#	print('werkjllwerj')
#	var room = find_room(room_id)
	for pid in player_list(room_id):
#		if pid != player_id:
		rpc_id(pid, "spin_man", deg)
	

remote func peer_change_room_dc(player_id):
	var room = find_room(PLAYER_DICT[player_id])
#	if room.get_children().size() != 0:
	_peer_connected(player_id)
		
	
	
#	if player_list.size() == 2:
#		rpc_id(player_list[0], "make_host")
#		rpc_id(player_list[1], "make_puppet")
	
	
	
#	PLAYER_DICT[player_id] = 

func delete_child(node, child):
	for c in node.get_children():
		if c.name == child.name:
			node.remove_child(c)
			c.queue_free()

remote func rpc_test(player_id, old_player_id, room_id):
	print("hello from ", player_id)
	for p in player_list(room_id):
		if player_id != p:
			rpc(p, "kill_old_player", old_player_id)
			
#
remote func start_game(room_id):
	print("started game?")
	for p in player_list(room_id):
		rpc_id(p, "start_game")
	




remote func move_player(vim_motion, player_id, room_id):
#	print("moved player ", player_id, " ", vim_motion)
	for p in player_list(room_id):
		if p != player_id:
			rpc_id(p, "move_player", vim_motion)	
#
remote func restart_game(room_id):
	for p in player_list(room_id):
		rpc_id(p, "restart_game")
#
remote func send_bullet(lister, player_id, room_id):
	for p in player_list(room_id):
		if player_id != p:
			rpc_id(p, "send_bullet", lister)
#
remote func spawn_npc(pos_arr, room_id):
	print("spawning npc i think ", pos_arr)
	for p in player_list(room_id):
		for pos in pos_arr:
			rpc_id(p, "spawn_npc", pos)
#
#remote func turn_npc(npc_name, angle, wait_time):
#
##	print("spawning npc i think ", pos_arr)
#	for p in player_list():
##		for :
#		rpc_id(p, "turn_npc", npc_name, angle, wait_time)
#
remote func hit_npc(npc_name, bullet_name, player_id, room_id):
	print("hit npc function aaaaaa")
#	print("spawning npc i think ", pos_arr)
	for p in player_list(room_id):
#		for :
		if p != player_id:
			rpc_id(p, "hit_npc", npc_name, bullet_name)

remote func turn_npc(npc_name, angle, wait_time, room_id):
	print("ok turning the npc")
	for p in player_list(room_id):
		print("player: ", p)
		rpc_id(p, "turn_npc", npc_name, angle, wait_time)
