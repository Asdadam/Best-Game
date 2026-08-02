extends CharacterBody2D

const SPEED : float = 130.0
const JUMP_VELOCITY : float = -300.0
const DASH_SPEED : float = 260.0
const WALL_SLIDE_SPEED : float = 40.0
const WALL_CLIMB_SPEED : float = -90.0
const WALL_JUMP_VELOCITY : Vector2 = Vector2(220.0, -280.0)
const WALL_JUMP_LOCK_TIME : float = 0.1
const COYOTE_TIME : float = 0.2

@onready var dash_duration: Timer = $Dash_duration
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var dashing : bool = false
var can_dash : float = true
var wall_jump_timer : float = 0.0
var coyote_timer : float = 0.0

func _ready() -> void:
	dash_duration.timeout.connect(_on_dash_timer_timeout)

func _physics_process(delta: float) -> void:
	if wall_jump_timer > 0:
		wall_jump_timer -= delta


	var direction := Input.get_axis("move_left", "move_right")

	var wall_normal := get_wall_normal().x
	var is_against_wall := is_on_wall() and ((direction > 0 and wall_normal < 0) or (direction < 0 and wall_normal > 0))
	
	if is_against_wall:
		can_dash = false
	else:
		can_dash = true

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
		coyote_timer =COYOTE_TIME


	if Input.is_action_just_pressed("Jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif is_on_wall() and not is_on_floor():
			velocity.y = WALL_JUMP_VELOCITY.y
			velocity.x = wall_normal * WALL_JUMP_VELOCITY.x
			wall_jump_timer = WALL_JUMP_LOCK_TIME


	if Input.is_action_just_pressed("dash") and not dashing and can_dash:
		dashing = true
		dash_duration.start()


	if dashing:
		var dash_dir = direction if direction != 0 else (-1.0 if animated_sprite.flip_h else 1.0)
		velocity.x = dash_dir * DASH_SPEED
	elif wall_jump_timer <= 0:
		if direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	if direction < 0 and wall_jump_timer <= 0:
		animated_sprite.flip_h = true
	elif direction > 0 and wall_jump_timer <= 0:
		animated_sprite.flip_h = false

	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	move_and_slide()

func _on_dash_timer_timeout() -> void:
	dashing = false
