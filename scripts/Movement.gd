extends Node2D


@onready var player: Player_Controller = $".."
@onready var animator: PlayerAnimator = $"../PlayerAnimator"
@onready var down_cd: Timer = $Down_cd
@onready var dash_duration: Timer = $Dash_duration
@onready var dash_cd: Timer = $Dash_cd


@export var SPEED : float = 160.0
@export var JUMP_VELOCITY : float = -300.0
@export var DASH_SPEED : float = 260.0
@export var WALL_SLIDE_SPEED : float = 40.0
@export var WALL_CLIMB_SPEED : float = -90.0
@export var WALL_JUMP_VELOCITY : Vector2 = Vector2(220.0, -280.0)
@export var WALL_JUMP_LOCK_TIME : float = 0.1
@export var COYOTE_TIME : float = 0.2
@export var WALL_STAND_TIME : float = 0.1
@export var JUMP_GRACE : float = 0.2
@export var acceleration : float = 1200.0
@export var friction : float = 250.0
@export var max_jump : int = 3


var wall_jump_timer : float = 0.0
var wall_stand_timer : float = 0.0
var coyote_timer : float = 0.0
var dash_dir : float = 0.0
var jumps_left : int = 0
var was_on_wall : bool = false
var jump_grace_timer : float = 0.0

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
		jumps_left = max_jump
		player.can_dash_air = true
	
	if jump_grace_timer > 0:
		jump_grace_timer -= delta
	
	
	if not player.is_on_floor():
		coyote_timer -= delta
		
		var can_wall_action : bool = is_against_wall and jump_grace_timer <= 0.0
		
		if can_wall_action:
			if not was_on_wall and player.velocity.y >= 0:
				wall_stand_timer = WALL_STAND_TIME
				player.velocity.y = 0.0
			was_on_wall = true
		
		if is_against_wall and coyote_timer <= 0 and jump_grace_timer:
			if Input.is_action_pressed("WallClimb"):
				player.velocity.y = WALL_CLIMB_SPEED 
				wall_stand_timer = 0.0
			elif wall_stand_timer > 0.0:
				player.velocity.y = 0
				wall_stand_timer -= delta
			else:
				player.velocity.y = WALL_SLIDE_SPEED
		else:
			was_on_wall = false
			wall_stand_timer = 0.0
			player.velocity.y += player.get_gravity().y * delta
	else:
		coyote_timer = COYOTE_TIME
		was_on_wall = false
		wall_stand_timer = 0.0

	if Input.is_action_just_pressed("Jump"):
		jump_grace_timer = JUMP_GRACE
		if airborn and jumps_left == max_jump:
			jumps_left -= 1
		
		if player.is_on_floor() or coyote_timer > 0.0 and not player.is_on_wall():
			coyote_timer = 0.0
			jumps_left -= 1
			player.velocity.y = JUMP_VELOCITY
		elif player.is_on_wall() and not player.is_on_floor():
			jumps_left -= 1
			player.velocity.y = WALL_JUMP_VELOCITY.y
			player.velocity.x = wall_normal * WALL_JUMP_VELOCITY.x
			wall_jump_timer = WALL_JUMP_LOCK_TIME
		elif jumps_left > 0:
			jumps_left -= 1
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
				dash_dir = dash_dir * -1
		player.dashing = true
		dash_duration.start()

	#DASH
	if player.dashing:
		player.pivot.scale.x = dash_dir
		player.velocity.x = dash_dir * DASH_SPEED
		player.velocity.y = 0
	elif wall_jump_timer <= 0:
		if player.direction != 0:
			player.velocity.x = move_toward(player.velocity.x, SPEED * player.direction,acceleration * delta)
		else:
			player.velocity.x = move_toward(player.velocity.x, 0, friction * delta)
	
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
