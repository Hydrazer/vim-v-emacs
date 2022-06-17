extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var STATE = ""
var PLAYER_ID
var PLAYER_DICT = {}
var TEAM = "NONE"
var RNG = RandomNumberGenerator.new()
var NPC_ID = 0
var BULLET_ID = 0
var VIM_BULLET_DICT = {}
var EMACS_BULLET_DICT = {}
var PLAYER_IMG = "res://Assets/vim64.png"
var ROOM_ID


# Called when the node enters the scene tree for the first time.
#func _ready():
	

# Called when the node enters the scene tree for the first time.
func _ready():
	RNG.randomize()
