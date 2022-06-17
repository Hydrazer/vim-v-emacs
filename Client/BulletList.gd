extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var BULLET_SC = preload("res://Bullet.tscn")
onready var EMACS_TEX = preload("res://Assets/emacs64.png")
var BULLET_SPEED = 10

const VIM_WAIT_TIME = 0.5


var SPAWN_BULLET = true

onready var SHOOT_TIMER: Timer = get_node("/root/Main/ShootTimer")

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("stopper")
#	get_node("/root/Server").connect("move_emac", self, "move_emacs")
	get_node("/root/Server").connect("send_bullet_emac_m", self, "send_bullet_emac")
#	pass # Replace with function body.

func freeze():
	SPAWN_BULLET = false

func _process(delta):
	if SPAWN_BULLET:
		spawn_bullet()
	move_bullet_vec()
	
master func move_emacs(move_vector):
#	print("move emacsv baby")
#	print("emacs move vec ", move_vector)
	var emacs = get_node("/root/Main/EmacsSpawn/Player/KinematicBody2D")
#	print(emacs)
	emacs.move_and_slide(move_vector)


func spawn_bullet():
	if Input.is_action_just_pressed("shoot") && SHOOT_TIMER.is_stopped():
		var vim = get_node("/root/Main/VimSpawn/Player/KinematicBody2D")
#		var player = get_node("/root/Main/VimSpawn")
		
		print("shot")
		var bullet = BULLET_SC.instance()
		
		

		get_node("/root/Main/BulletList").add_child(bullet)
		bullet.name = "BULLET-%d" % [Glob.BULLET_ID]
		
		
		bullet.global_position = vim.global_position
		Glob.VIM_BULLET_DICT[bullet.name] = [bullet.global_position, Vector2(BULLET_SPEED, 0)]
		Server.serv_send_bullet([bullet.global_position, Vector2(BULLET_SPEED, 0)], Glob.PLAYER_ID, Glob.ROOM_ID)

		SHOOT_TIMER.wait_time = VIM_WAIT_TIME
		SHOOT_TIMER.start()
		
		Glob.BULLET_ID += 1


master func move_bullet_vec():
#	print(len(VIM_BULLET_DICT), len(EMACS_BULLET_DICT))
	

	for b in Glob.VIM_BULLET_DICT:
		var bul = get_node_or_null("/root/Main/BulletList/"+b)
		if bul:
			bul.global_position += Glob.VIM_BULLET_DICT[b][1]
		else:
			Glob.VIM_BULLET_DICT.erase(b)
	
	for b in Glob.EMACS_BULLET_DICT:
#		if b:
		var bul = get_node_or_null("/root/Main/BulletList/"+b)
		if bul:
			bul.global_position += Glob.EMACS_BULLET_DICT[b][1]
		else:
			Glob.EMACS_BULLET_DICT.erase(b)

func send_bullet_emac(lister):
	print("sending bullet emac ", lister)
	var emacs = get_node("/root/Main/EmacsSpawn/Player/KinematicBody2D")
#	var bullet = BULLET_SC.instance()
	
	var bullet = BULLET_SC.instance()
#
	get_node("/root/Main/BulletList").add_child(bullet)
	bullet.get_node("Sprite").texture = EMACS_TEX
	bullet.global_position = emacs.global_position
	bullet.name = "BULLET-%d" % [Glob.BULLET_ID]
	bullet.BULLET_ACTIVE = false
	
#	var player = get_node("/root/Main/VimSpawn")
	Glob.EMACS_BULLET_DICT[bullet.name] = [bullet.global_position, Vector2(-BULLET_SPEED, 0)]
	Glob.BULLET_ID += 1
