extends CharacterBody2D

class_name Player_Controller


@onready var combat_manager: Node2D = $CombatManager
@onready var dash_duration: Timer = $MovementManager/Dash_duration
@onready var hit_box: Area2D = $Pivot/HitBox
@onready var pivot: Node2D = $Pivot
@onready var dash_cd: Timer = $MovementManager/Dash_cd
@onready var animator: PlayerAnimator = $PlayerAnimator # Yeni animasyon düğümü
@onready var down_cd: Timer = $MovementManager/Down_cd
@onready var camera_2d: Camera2D = $Camera2D

#Kamera Limitleri
@export var camera_left_limit : int 
@export var camera_top_limit : int 
@export var camera_right_limit : int 
@export var camera_bottom_limit : int 


const HOLD_TIME : float = 0.7

var dashing : bool = false
var can_dash : bool = true
var is_attacking : bool = false
var can_dash_air : bool = true
var dash_from_wall : bool = false
var direction : float = 0.0
var falling : bool = false
var can_down : bool = true
var camera_travel_distance : float = -50
var hold_timer : float = 0.0
var camera_default_y : float
var look_state : int = 0
var camera_tween : Tween
var cam_limit_set : bool = false

func _ready() -> void:
	camera_default_y = camera_2d.position.y

func _process(delta: float) -> void:
	if !cam_limit_set:
		camera_2d.limit_left = camera_left_limit
		camera_2d.limit_right = camera_right_limit
		camera_2d.limit_bottom = camera_bottom_limit
		camera_2d.limit_top = camera_top_limit
		cam_limit_set = true



	if Input.is_action_pressed("look_up") and look_state == 0:
		hold_timer += delta
		if hold_timer >= HOLD_TIME:
			look_state = 1
			look_up_down(look_state)
	elif Input.is_action_pressed("look_down") and look_state == 0:
		hold_timer += delta
		if hold_timer >= HOLD_TIME:
			look_state = -1
			look_up_down(look_state)

	if Input.is_action_just_released("look_up") or Input.is_action_just_released("look_down"):
		hold_timer = 0.0
		look_state = 0
		look_up_down(look_state)



	direction = Input.get_axis("move_left", "move_right")
	get_platform()
	if direction > 0 and not dashing:
		pivot.scale.x = 1
	elif direction < 0 and not dashing:
		pivot.scale.x = -1
	if Input.is_action_just_pressed("move_down") and down_cd.time_left <= 0:
		down_cd.start()

func get_platform() -> Node2D:
	if get_last_slide_collision() != null:
		return get_last_slide_collision().get_collider()
	return null


func look_up_down(state : int) -> void:
	if camera_tween and camera_tween.is_valid():
		camera_tween.kill()

	camera_tween = create_tween()
	camera_tween.set_trans(Tween.TRANS_SINE)
	camera_tween.set_ease(Tween.EASE_OUT)

	match state:
		1:
			camera_tween.tween_property(camera_2d, "position:y", -50.0, 0.5)
		0:
			camera_tween.tween_property(camera_2d, "position:y", 0.0, 0.3)
		-1:
			camera_tween.tween_property(camera_2d, "position:y", 50.0, 0.5)
