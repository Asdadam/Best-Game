extends CharacterBody2D

@export_category("Stats")

@export var hit_points : int = 50
@onready var hp: Label = $HP
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var trigger_zone: Area2D = $TriggerZone
@onready var pursue_timer: Timer = $PursueTimer


@export var speed : float = 65.0
@export var stoping_distance : float = 8.0
@export var jump_velocity : float = -300.0

var target : Variant = null
var player: Node2D = null
var direction : int 
var pursuing : bool = false
var is_dead : bool = false

func _ready() -> void:
	is_dead = false
	hp.text = str(hit_points)
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	trigger_zone.body_entered.connect(_on_body_entered)
	trigger_zone.body_exited.connect(_on_body_exited)
	pursue_timer.timeout.connect(_on_pursue_ended)

func _physics_process(delta: float) -> void:
	if is_dead:
		speed = 0.0
		move_and_slide()
		velocity.x = 0.0
		
	if hit_points <= 0:
		is_dead = true
		animated_sprite_2d.play("Death")
	hp.text = str(hit_points)
	
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	else:
		velocity.y= 0
	
	if animated_sprite_2d.flip_h:
		direction = 1
	else:
		direction = -1
	
	var wall_normal := get_wall_normal().x
	var is_against_wall : bool = is_on_wall() and ((direction > 0 and wall_normal < 0) or (direction < 0 and wall_normal > 0))


	if player:
		target = player.global_position.x
		
	if target != null:
		var distance : float = target - global_position.x
		
		if abs(distance) > stoping_distance:
			var dir : float = sign(distance)
			velocity.x = dir * speed
			
			if dir >= 0:
				animated_sprite_2d.flip_h = true
			else:
				animated_sprite_2d.flip_h = false
		
		if is_against_wall and is_on_floor() and pursuing:
			velocity.y = jump_velocity
		
	elif pursuing:
		velocity.x = direction * speed
	else:
		velocity.x = 0
	move_and_slide()
func take_damage(damage_taken : int):
	hit_points -= damage_taken

func _on_animation_finished():
	if animated_sprite_2d.animation == "Death":
		death()

func _on_body_entered(body : Node2D):
	if body.is_in_group("Player"):
		pursue_timer.stop()
		player = body
		pursuing = false

func _on_body_exited(body : Node2D):
	if body.is_in_group("Player"):
		pursue_timer.start()
		pursuing = true

func _on_pursue_ended():
	target = null
	pursuing = false
	player = null

func death():
	queue_free()
	
func killzone_death():
	animated_sprite_2d.play("Death")
	
