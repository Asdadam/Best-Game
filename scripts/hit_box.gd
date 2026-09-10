extends Area2D

@onready var player: CharacterBody2D = $"../.."
@onready var combat_manager: Node2D = $"../../CombatManager"







func _on_area_entered(area: Area2D) -> void:
	var facing : bool = false if area.owner.direction * player.direction > 0 else true
	if player.is_attacking:
		if area.owner.has_method("take_damage") and facing:
			area.owner.take_damage(50)
