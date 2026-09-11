extends Node2D

@onready var player: Player_Controller = $Player


func _ready() -> void:
	AudioManager.play_music(AudioManager.medieval_bg)
	
	var camera: Camera2D = player.get_node_or_null("Camera2D")
	
	camera.limit_left = -150
	camera.limit_top = -255
	camera.limit_right = 815
	camera.limit_bottom = 150
