extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#signal serv_restart_game

var SCREEN_DIM = Vector2(1024, 600)
onready var PLAYER_SC = preload("res://Player.tscn")
onready var NPC_SC = preload("res://NPC.tscn")
onready var GAME_TIMER = $GameTimer

var STATE
var SHOWED_WINNER = false 
var DISCONNECT = false
#var NPC_ID = 1


#var rng = RandomNumberGenerator.new()



# Called when the node enters the scene tree for the first time.
func _ready():
	Glob.NPC_ID = 0
	Glob.BULLET_ID = 0
	var vim_player = PLAYER_SC.instance()
	$VimSpawn.add_child(vim_player)

	var emacs_player = PLAYER_SC.instance()
	$EmacsSpawn.add_child(emacs_player)
#	
	$EmacsSpawn/Player/KinematicBody2D/Sprite.texture = load("res://Assets/emacs64.png")
		
	if Glob.TEAM == "vim":
		Server.serv_spawn_npc(Glob.ROOM_ID)
	
func point_count(team):
	var total = 0

	for c in $NPCList.get_children():
#		print(c.get_node("NPC/Sprite").texture.resource_path )
		if team == "Vim" && c.get_node("KinematicBody2D/NPCSprite").texture.resource_path == "res://Assets/vim_man.png":
			total += 1
		elif team == "Emacs" && c.get_node("KinematicBody2D/NPCSprite").texture.resource_path == "res://Assets/emacs_man.png":
			total += 1

	return total
#
func _process(_delta):

	var emacs_point = point_count("Emacs")
	var vim_point = point_count("Vim")

	$EmacsPoint.text = emacs_point as String
	$VimPoint.text = vim_point as String

#	var Game
#	var game_time = 

	$CenterContainer/GameLabel.text = int(GAME_TIMER.time_left) as String


	if not DISCONNECT && GAME_TIMER.is_stopped() && not SHOWED_WINNER:
		STATE = stop_game(vim_point, emacs_point)
#
	if $BulletList.get_children().size() == 0 && STATE:
#		print(STATE)
		STATE.resume()
		STATE = null
#
#
##		yield(wait_bullet_gone(), "bullet_gone")
#
#
#
func stop_game(vim_point, emacs_point):
	SHOWED_WINNER = true
	get_tree().call_group("stopper", "freeze")
	yield()
	
	$WinCenterContainer/WinLabel.text = "Vim Wins" if vim_point > emacs_point else "Tie" if vim_point == emacs_point else "Emacs Wins" 

	if Glob.TEAM == "vim":
		$PlayAgainButton.show()
#
#
func _on_PlayAgainButton_button_down():
	Server.serv_restart_game(Glob.ROOM_ID)


func _on_MainMenuButton_button_down():
	call_deferred("_deferred_change_scene", 'res://MainMenu.tscn')
	Server.peer_change_room_dc_serv(Glob.PLAYER_ID)
	
func _deferred_change_scene(new_scene_path):
	var root = get_tree().get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
	set_process(false)
	current_scene.queue_free()
	current_scene = load(new_scene_path).instance()
	root.add_child(current_scene)
	get_tree().set_current_scene(current_scene)
#	pass # Replace with function body.
