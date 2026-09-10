extends Area2D

@onready var timer: Timer = $Timer

 
func _on_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		body.can_dash_air = false
		body.is_attacking = true
		body.set_process(false)
		var movement_manager = body.get_node_or_null("MovementManager")
		movement_manager.max_jump = 0
		Engine.time_scale = 0.5
		body.get_node("CollisionShape2D").queue_free()
		timer.start()
	elif body.is_in_group("Enemy"):
		if body.has_method("killzone_death"):
			body.killzone_death()


func _on_timer_timeout():
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
