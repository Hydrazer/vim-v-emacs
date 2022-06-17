extends Control


onready var MOVE_TIMER = get_node("KinematicBody2D/MoveTimer")
var VEL_VEC = Vector2(0, 0)
var SPEED = 50
#var NAME
signal hit_npc(npc, bullet)



# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("hit_npc", get_node("/root/Main/NPCList"), "hit_npc")
	get_node("/root/Server").connect("turn_npc_m", self, "turn_npc")
#	pass # Replace with function body.



func turn_npc(npc_name, angle, wait_time):
	print("turning npc", npc_name, " || ", self.name, " || ", angle, " || ", wait_time)
	if self.name == npc_name:
		MOVE_TIMER.wait_time = wait_time
		MOVE_TIMER.start()
		$KinematicBody2D/NPCSprite.set_rotation_degrees(angle if Glob.TEAM == "vim" else -angle)

		# in radians
		var angle_r = $KinematicBody2D/NPCSprite.get_rotation() 
		VEL_VEC = Vector2.UP.rotated(angle_r) * SPEED

func _process(delta):
#	print(Glob.TEAM)
	if MOVE_TIMER.is_stopped() && Glob.TEAM == "vim":
#		print("move timer reach my guy")
		MOVE_TIMER.wait_time = 6969
		MOVE_TIMER.start()
		Server.serv_turn_npc(self.name, Glob.ROOM_ID)

	$KinematicBody2D.move_and_slide(VEL_VEC)


func _on_Area2D_area_entered(area_hit):
	if ("BULLET-" in area_hit.name && area_hit.BULLET_ACTIVE == false) or area_hit.get_parent().get_node_or_null("NPCSprite"):
		return
	
#	BULLET_ACTIVE = false
	var bullet = area_hit
	bullet.BULLET_ACTIVE = false
	bullet.hide()
	
	
#	var npc_sprite = $KinematicBody2D/NPCSprite
	
#	if npc_sprite:
	emit_signal("hit_npc", self, bullet)
#	pass # Replace with function body.
