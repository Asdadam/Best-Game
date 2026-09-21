extends Area2D

@onready var player: CharacterBody2D = $"../.."
@onready var combat_manager: Node2D = $"../../CombatManager"

@export var attack_resource : AttackResource






func _on_area_entered(area: Area2D) -> void:
	var target : Node = area.owner
	var target_def_friction : float = target.friction
	var target_current_health : int = target.hit_points
	var knocknack_velocity : float = 200.0
	if not target or not target_def_friction or not target.hit_points:
		return
	var facing : bool = false if target.direction * player.direction > 0 else true
	if player.is_attacking:
		if target.has_method("take_damage") and facing:
			match attack_resource.damage_type:
				0:
					var tick_timer := Timer.new()
					tick_timer.autostart = false
					tick_timer.one_shot = false
					tick_timer.wait_time = 0.5
					
					var damage_timer := Timer.new()
					damage_timer.autostart = false
					damage_timer.one_shot = true
					damage_timer.wait_time = 2
					
					add_child(damage_timer)
					add_child(tick_timer)
					
					
					target.take_damage(attack_resource.damage)
					apply_attack_knockback()
					damage_timer.start()
					tick_timer.start()
						
					while damage_timer.time_left > 0.0 and target:
						await tick_timer.timeout
						
						if not target.is_dead and target and target.has_method("take_damage"):
							target.take_damage(10)
						else:
							break
				1:
					target.take_damage(attack_resource.damage)
					apply_attack_knockback()
					target.friction = 450.0
					target.speed = 30.0
					var slip_timer := Timer.new()
					slip_timer.autostart = false
					slip_timer.one_shot = true
					slip_timer.wait_time = 3.0
					add_child(slip_timer)
					slip_timer.start()
					 
					await slip_timer.timeout
					target.friction = target_def_friction
					target.speed = 65.0
				2:
					target.take_damage(attack_resource.damage)
					apply_attack_knockback()
					if target.dir > 0:
						target.velocity.x -= knocknack_velocity
					elif target.dir < 0:
						target.velocity.x += knocknack_velocity
				3:
					target.take_damage(attack_resource.damage)
					apply_attack_knockback()
					var stun_time := Timer.new()
					stun_time.autostart = false
					stun_time.one_shot = true
					stun_time.wait_time = 3.0
					add_child(stun_time)
					stun_time.start()
					if not target_current_health == target.hit_points:
						target.speed = 0.0
						target.velocity.x = 0.0
					await stun_time.timeout
					target.speed = 65.0


func apply_attack_knockback() -> void:
	player.velocity.x = -player.pivot.scale.x * player.knockback_velocity
