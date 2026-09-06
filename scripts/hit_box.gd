extends Area2D

@onready var player: CharacterBody2D = $"../.."
@onready var combat_manager: Node2D = $"../../CombatManager"

var damage_dealt : bool = false


func _on_area_entered(area: Area2D) -> void:
	if player.is_attacking:
		if area.owner.has_method("take_damage") and not damage_dealt:
			area.owner.take_damage(50)
			damage_dealt = true
			combat_manager.damage_dealt_timer.start()

func _on_damage_dealt_timeout() -> void:
	damage_dealt = false
