extends VBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var PLAYER_SC = preload("res://Player.tscn")
onready var NPC_SC = preload("res://NPC.tscn")

onready var EMACS_MAN = preload("res://Assets/emacs_man.png")
onready var VIM_MAN = preload("res://Assets/vim_man.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("/root/Server").connect("spawn_npc_m", self, "spawn_npc")
	get_node("/root/Server").connect("hit_npc_m", self, "hit_npc_m")
#	pass # Replace with function body.

func spawn_npc(pos):
	var npc_con = NPC_SC.instance()
	get_node("/root/Main/NPCList").add_child(npc_con)
	
	
	
#	npc_con.name = "NPC_CON"GLOB.NPC_ID
	
	npc_con.name = "NPC-%d" % [Glob.NPC_ID]
#	print()
	
	
	var npc = npc_con.get_node("KinematicBody2D")
	if Glob.TEAM == "vim":
		npc.global_position = pos
	else:
		pos.x = 1024 - pos.x
		npc.global_position = pos
	print("npc pos ", npc.global_position)
	Glob.NPC_ID += 1

func hit_npc(npc, bullet):
	print("hit me ", npc.name, " || ", bullet.name)
	
	var npc_sprite = npc.get_node("KinematicBody2D/NPCSprite")
#	print(npc_sprite.get_parent())

	Server.serv_hit_npc(npc.name, bullet.name, Glob.PLAYER_ID, Glob.ROOM_ID)

	npc_sprite.texture = VIM_MAN
#	bullet.get_node("CollisionShape2D").disabled = true
#	bullet.get_parent().remove_child(bullet)	
#	bullet.queue_free()

func hit_npc_m(npc_name, bullet_name):
#	pass
	var npc
	for n in get_node("/root/Main/NPCList").get_children():
		print("my man npc name ", n.name,  " || ", npc_name)
		if n.name == npc_name:
			npc = n

	var bullet
	for n in get_node("/root/Main/BulletList").get_children():
		print("my man bullet name ", n.name, " || ", npc_name)
		if n.name == bullet_name:
			bullet = n
	
	var npc_sprite = npc.get_node("KinematicBody2D/NPCSprite")
	npc_sprite.texture = EMACS_MAN
	bullet.hide()
