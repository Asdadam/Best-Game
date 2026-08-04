extends CharacterBody2D

#Değişkenler
const SPEED : float = 130.0
const JUMP_VELOCITY : float = -300.0
const DASH_SPEED : float = 260.0
const WALL_SLIDE_SPEED : float = 40.0
const WALL_CLIMB_SPEED : float = -90.0
const WALL_JUMP_VELOCITY : Vector2 = Vector2(220.0, -280.0)
const WALL_JUMP_LOCK_TIME : float = 0.1
const COYOTE_TIME : float = 0.2




@onready var dash_duration: Timer = $Dash_duration
@onready var animated_sprite: AnimatedSprite2D = $Pivot/AnimatedSprite2D
@onready var first_attack: AnimationPlayer = $firstAttack
@onready var hit_box: Area2D = $Pivot/HitBox
@onready var pivot: Node2D = $Pivot
@onready var second_attack: AnimationPlayer = $secondAttack
@onready var combo_timer: Timer = $combo_timer



var dashing : bool = false
var can_dash : bool = true
var wall_jump_timer : float = 0.0
var coyote_timer : float = 0.0
var is_attacking : bool = false
var attack_count : int = 0



func _ready() -> void:
	dash_duration.timeout.connect(_on_dash_timer_timeout)
	first_attack.animation_finished.connect(_on_animation_finished)
	second_attack.animation_finished.connect(_on_animation_finished)
	combo_timer.timeout.connect(_on_combo_finished)

func _physics_process(delta: float) -> void:
	if wall_jump_timer > 0:
		wall_jump_timer -= delta

	var direction := Input.get_axis("move_left", "move_right")#Oyuncunun gittiği taraf
	var wall_normal := get_wall_normal().x#Duvarın normali
	#Duvara yapışmışsak duvarın normaliile ters yöne bakmalıyız
	var is_against_wall := is_on_wall() and ((direction > 0 and wall_normal < 0) or (direction < 0 and wall_normal > 0))
	
	if direction < 0:
		pivot.scale.x = -1
	elif direction > 0:
		pivot.scale.x = 1
	else:
		pass
	
	if is_against_wall:
		can_dash = false
	else:
		can_dash = true

	if not is_on_floor():
		coyote_timer -= delta#Zıpladıktan sonra hemen duvara yapışmamak için araya küçük bir süre sıkıştırdım
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
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif is_on_wall() and not is_on_floor():
			velocity.y = WALL_JUMP_VELOCITY.y
			velocity.x = wall_normal * WALL_JUMP_VELOCITY.x
			wall_jump_timer = WALL_JUMP_LOCK_TIME

	if Input.is_action_just_pressed("dash") and not dashing and can_dash:
		if is_attacking:
			is_attacking = false
			first_attack.stop()
		dashing = true
		dash_duration.start()
		animated_sprite.play("dash")

	if dashing:
		#Yerimzide durmuyorsak gittiğimiz yöne dash,yerimizde duruyorsak baktığımız yere dash atmak için Dash_speed ile çarpacağımız vektör
		var dash_dir = direction if direction != 0 else (-1.0 if pivot.scale.x == -1 else 1.0)
		velocity.x = dash_dir * DASH_SPEED
	elif wall_jump_timer <= 0:
		if direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)


	if Input.is_action_just_pressed("attack") and not is_attacking and not dashing and not is_against_wall:
		attack()
		if attack_count <= 1:
			attack_count +=1
		else:
			attack_count = 0
		


	if not is_attacking:
		if is_on_floor():
			if direction == 0:
				if dashing:
					animated_sprite.play("dash")
				else:
					animated_sprite.play("idle")
			else:
				if dashing:
					animated_sprite.play("dash")
				else:
					animated_sprite.play("run")
		else:
			if velocity.y > 0:
				if dashing:
					animated_sprite.play("dash")
				else:
					animated_sprite.play("falling")
			else:
				if dashing:
					animated_sprite.play("dash")
				else:
					animated_sprite.play("jumping")
			


	move_and_slide()

func attack():
	if attack_count == 0:
		is_attacking = true
		first_attack.play("attack")
		animated_sprite.play("attack")
	elif attack_count == 1:
		is_attacking = true
		second_attack.play("secondAttack")
		animated_sprite.play("2Attack")

func _on_dash_timer_timeout() -> void:
	dashing = false

func _on_animation_finished(anim_name : StringName):
	if anim_name == "attack" or "2Attack":
		is_attacking = false

func _on_combo_finished():
	attack_count = 0
