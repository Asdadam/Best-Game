extends Area2D

@onready var player: CharacterBody2D = $"../.."

func _on_area_entered(area: Area2D) -> void:
	if player.is_attacking:
		area.owner.take_damage(50)
