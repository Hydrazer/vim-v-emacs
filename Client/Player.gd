extends VBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#signal move_player(vim_motion, player_id)

var EMACS_MOTION := Vector2()
var VIM_MOTION := Vector2()
var FRICTION = 1.1
var SPEED_Y = 8


var tick = 0




#onready var EMACS_TIMER = get_node("/root/Main/EmacsTimer")




#onready var EMACS_TIMER = get_node("/root/Main/EmacsTimer")
#onready var VIM_TIMER: Timer = get_node("/root/Main/VimTimer")

func _ready():
	add_to_group("stopper")
	get_node("/root/Server").connect("move_emac_m", self, "move_emac")
	
	

	



#	get_node("/root/Main/BulletList").add_child(bullet)
#
#	bullet.global_position = Vector2(1024, 0) - lister[0]
#	EMACS_BULLET_DICT[bullet.name] = [bullet.global_position, lister[1] * -1]
#	Server.serv_send_bullet([bullet.global_position, lister[1]], Glob.PLAYER_ID)
	
	
#	self.connect("move_player", get_node("/root/Server"), "serv_move_player")
#	get_node("/root/")
#	add_to_group("stopper")

func freeze():
#	print("freeze?")
	set_process(false)

func _process(_delta):
#	print("tick ", tick, " ", Glob.PLAYER_ID, " ",  self.is_network_master())
#	_send_player_state()
#	move_bullet_vec()
	_movement_loop()
	tick += 1
#	var emacs = get_node("/root/Main/EmacsSpawn/Player/KinematicBody2D")
#	var vim = get_node("/root/Main/VimSpawn/Player/KinematicBody2D")
	pass




	
func _movement_loop():
	
	var vim = get_node("/root/Main/VimSpawn/Player/KinematicBody2D")
	
#	if $
	if Input.is_action_pressed("ui_up") && Input.is_action_pressed("ui_down"):
		VIM_MOTION.y = 0
		
	elif Input.is_action_pressed("ui_up"):
		VIM_MOTION.y -= SPEED_Y
		if VIM_MOTION.y > 0:
			VIM_MOTION.y = VIM_MOTION.y / FRICTION
			
	elif Input.is_action_pressed("ui_down"):
		VIM_MOTION.y += SPEED_Y
		if VIM_MOTION.y < 0:
			VIM_MOTION.y = VIM_MOTION.y / FRICTION
		
	else:
		VIM_MOTION.y = VIM_MOTION.y / FRICTION

	vim.move_and_slide(VIM_MOTION)
	Server.serv_move_player(VIM_MOTION, Glob.PLAYER_ID, Glob.ROOM_ID)

func move_emac(move_vector):
#	print("move emacsv baby")
#	print("emacs move vec ", move_vector)
	var emacs = get_node("/root/Main/EmacsSpawn/Player/KinematicBody2D")
#	print(emacs)
	emacs.move_and_slide(move_vector)
