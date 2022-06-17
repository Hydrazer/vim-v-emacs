extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#signal start_game



# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	self.connect("start_game", get_node("/root/Server"), "serv_start_game")
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	pass
	
	display_player()

func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()	

func display_player():
	delete_children($PlayerList)
	for p in Glob.PLAYER_DICT:
		var label = Label.new()
		$PlayerList.add_child(label)
		label.text = p as String


func _on_PlayButton_button_down():
	Server.serv_start_game(Glob.ROOM_ID)
