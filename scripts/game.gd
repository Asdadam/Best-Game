extends Node2D

@onready var player: Player_Controller = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var camera: Camera2D = player.get_node_or_null("Camera2D")	
	
	camera.limit_left = -150
	camera.limit_top = -255
	camera.limit_right = 815
	camera.limit_bottom = 150
