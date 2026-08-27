extends CharacterBody2D

class_name Player_Controller

# Değişkenler
const SPEED : float = 130.0
const JUMP_VELOCITY : float = -300.0
const DASH_SPEED : float = 260.0
const WALL_SLIDE_SPEED : float = 40.0
const WALL_CLIMB_SPEED : float = -90.0
const WALL_JUMP_VELOCITY : Vector2 = Vector2(220.0, -280.0)
const WALL_JUMP_LOCK_TIME : float = 0.1
const COYOTE_TIME : float = 0.2


@onready var dash_duration: Timer = $Dash_duration
@onready var hit_box: Area2D = $Pivot/HitBox
@onready var pivot: Node2D = $Pivot
@onready var combo_timer: Timer = $combo_timer
@onready var dash_cd: Timer = $Dash_cd
@onready var animator: PlayerAnimator = $PlayerAnimator # Yeni animasyon düğümü
@onready var down_cd: Timer = $Down_cd


var dashing : bool = false
var can_dash : bool = true
var wall_jump_timer : float = 0.0
var coyote_timer : float = 0.0
var is_attacking : bool = false
var attack_count : int = 0
var can_dash_air : bool = true
var dash_from_wall : bool = false
var dash_dir : float = 0.0
var direction : float = 0.0
var max_jump : int = 2
var falling : bool = false
var jump_counter : float = 0.0
var can_down := true

func _ready() -> void:
	dash_duration.timeout.connect(_on_dash_timer_timeout)
	dash_cd.timeout.connect(_on_dash_cd_timer_timeout)
	combo_timer.timeout.connect(_on_combo_finished)
	down_cd.timeout.connect(_on_down_cd_timeout)

func _physics_process(delta: float) -> void:
	direction = Input.get_axis("move_left", "move_right")
	
	
	if wall_jump_timer > 0:
		wall_jump_timer -= delta
	
	
	
	#YANLIŞLIKLA DUVARA YAPIŞMAMAK İÇİN(KISMEN)
	var wall_normal := get_wall_normal().x
	var is_against_wall := is_on_wall() and ((direction > 0 and wall_normal < 0) or (direction < 0 and wall_normal > 0))
	var airborn := not is_on_floor() and not is_on_wall()
	
	if direction < 0:
		pivot.scale.x = -1
	elif direction > 0:
		pivot.scale.x = 1
	
	#DASH RESETİ
	if is_on_floor() or is_against_wall:
		max_jump = 2
		can_dash_air = true
	
	#WALLCLİMB
	if not is_on_floor():
		coyote_timer -= delta
		if is_against_wall and coyote_timer <= 0:
			if Input.is_action_pressed("WallClimb"):
				velocity.y = WALL_CLIMB_SPEED 
			else:
				velocity.y = WALL_SLIDE_SPEED 
		else:
			velocity.y += get_gravity().y * delta
	else:
		coyote_timer = COYOTE_TIME

	if Input.is_action_just_pressed("Jump"):
		if airborn and max_jump == 2:
			max_jump -= 1
		
		if is_on_floor() and max_jump > 0:
			max_jump -= 1
			velocity.y = JUMP_VELOCITY
		elif is_on_wall() and not is_on_floor() and max_jump > 0:
			max_jump -= 1
			velocity.y = WALL_JUMP_VELOCITY.y
			velocity.x = wall_normal * WALL_JUMP_VELOCITY.x
			wall_jump_timer = WALL_JUMP_LOCK_TIME
		elif not is_on_wall() and not is_on_floor() and max_jump > 0:
			max_jump -= 1
			velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("dash") and not dashing and can_dash and can_dash_air:
		if is_attacking: 
			is_attacking = false
			animator.stop_attack()
		if not is_on_floor():
			can_dash_air = false
		dash_dir = direction if direction != 0 else (-1.0 if pivot.scale.x == -1 else 1.0)
		if is_on_wall() and not is_on_floor():
			if  Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_D):
				dash_dir *= -1
		dashing = true
		dash_duration.start()

	#DASH
	if dashing:
		pivot.scale.x = dash_dir
		velocity.x = dash_dir * DASH_SPEED
		velocity.y = 0
	elif wall_jump_timer <= 0:
		if direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	#ATTACK
	if Input.is_action_just_pressed("attack") and not is_attacking and not dashing and not is_against_wall:
		attack()
		combo_timer.start()
		attack_count = (attack_count + 1) % 2

	if Input.is_action_just_pressed("move_down") and down_cd.time_left <= 0:
		down_cd.start()
			
	



	move_and_slide()

func attack():
	is_attacking = true
	animator.play_attack(attack_count)

func _on_dash_timer_timeout() -> void:
	dashing = false
	can_dash = false
	dash_from_wall = false
	dash_cd.start()

func _on_combo_finished():
	attack_count = 0

func _on_dash_cd_timer_timeout():
	can_dash = true
		

#ONE-WAYLERDE AŞAĞI İNMEYİ YAPAR
func _input(event):
	if event.is_action_pressed("move_down") and can_down and is_on_floor():
		can_down = false
		set_collision_mask_value(9, false)
		down_cd.start()
	
	
	
func _on_down_cd_timeout() -> void:
	can_down = true
	set_collision_mask_value(9, true)
