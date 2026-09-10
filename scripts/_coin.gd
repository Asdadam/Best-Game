extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_body_entered(_body: Node2D):
	animation_player.play("pickup")
