extends Node2D

@onready var player: Player_Controller = $Player


func _ready() -> void:
	AudioManager.play_music(AudioManager.medieval_kale)
	
	var camera: Camera2D = player.get_node_or_null("Camera2D")	
	
	camera.limit_left = -305
	camera.limit_top = -10000000
	camera.limit_right = 1550
	camera.limit_bottom = 650
