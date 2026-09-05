extends Node2D


@onready var player: Player_Controller = $".."
@onready var animator: PlayerAnimator = $"../PlayerAnimator"
@onready var down_cd: Timer = $Down_cd
@onready var dash_duration: Timer = $Dash_duration
@onready var dash_cd: Timer = $Dash_cd


const SPEED : float = 130.0
const JUMP_VELOCITY : float = -300.0
const DASH_SPEED : float = 260.0
const WALL_SLIDE_SPEED : float = 40.0
const WALL_CLIMB_SPEED : float = -90.0
const WALL_JUMP_VELOCITY : Vector2 = Vector2(220.0, -280.0)
const WALL_JUMP_LOCK_TIME : float = 0.1
const COYOTE_TIME : float = 0.2

var wall_jump_timer : float = 0.0
var coyote_timer : float = 0.0
var dash_dir : float = 0.0
var jump_counter : float = 0.0
var max_jump : int = 2

func _ready() -> void:
	dash_duration.timeout.connect(_on_dash_timer_timeout)
	dash_cd.timeout.connect(_on_dash_cd_timer_timeout)
	down_cd.timeout.connect(_on_down_cd_timeout)


func _physics_process(delta: float) -> void:
	
	if wall_jump_timer > 0:
		wall_jump_timer -= delta
	
	var wall_normal := player.get_wall_normal().x
	var is_against_wall := player.is_on_wall() and ((player.direction > 0 and wall_normal < 0) or (player.direction < 0 and wall_normal > 0))
	var airborn := not player.is_on_floor() and not player.is_on_wall()
	
	if player.is_on_floor() or is_against_wall or player.is_on_wall():
		max_jump = 2
		player.can_dash_air = true
		
	
	if not player.is_on_floor():
		coyote_timer -= delta
		if is_against_wall and coyote_timer <= 0:
			if Input.is_action_pressed("WallClimb"):
				player.velocity.y = WALL_CLIMB_SPEED 
			else:
				player.velocity.y = WALL_SLIDE_SPEED 
		else:
			player.velocity.y += player.get_gravity().y * delta
	else:
		coyote_timer = COYOTE_TIME

	if Input.is_action_just_pressed("Jump"):
		if airborn and max_jump == 2:
			max_jump -= 1
		
		if player.is_on_floor() and max_jump > 0:
			max_jump -= 1
			player.velocity.y = JUMP_VELOCITY
		elif player.is_on_wall() and not player.is_on_floor() and max_jump > 0:
			max_jump -= 1
			player.velocity.y = WALL_JUMP_VELOCITY.y
			player.velocity.x = wall_normal * WALL_JUMP_VELOCITY.x
			wall_jump_timer = WALL_JUMP_LOCK_TIME
		elif not player.is_on_wall() and not player.is_on_floor() and max_jump > 0:
			max_jump -= 1
			player.velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("dash") and not player.dashing and player.can_dash and player.can_dash_air:
		if player.is_attacking: 
			player.is_attacking = false
			animator.stop_attack()
		if not player.is_on_floor():
			player.can_dash_air = false
		dash_dir = player.direction if player.direction != 0 else (-1.0 if player.pivot.scale.x == -1 else 1.0)
		if player.is_on_wall() and not player.is_on_floor():
			if  Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_D):
				dash_dir *= -1
		player.dashing = true
		dash_duration.start()

	#DASH
	if player.dashing:
		player.pivot.scale.x = dash_dir
		player.velocity.x = dash_dir * DASH_SPEED
		player.velocity.y = 0
	elif wall_jump_timer <= 0:
		if player.direction != 0:
			player.velocity.x = player.direction * SPEED
		else:
			player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
	
	if Input.is_action_just_pressed("move_down"):
		move_down()
		
	player.move_and_slide()




func move_down() -> void:
	player.can_down = false
	player.set_collision_mask_value(9, false)
	down_cd.start()


func _on_dash_timer_timeout() -> void:
	player.dashing = false
	player.can_dash = false
	player.dash_from_wall = false
	dash_cd.start()

func _on_dash_cd_timer_timeout():
	player.can_dash = true

func _on_down_cd_timeout() -> void:
	player.can_down = true
	player.set_collision_mask_value(9, true)
