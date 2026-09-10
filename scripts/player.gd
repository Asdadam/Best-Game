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


var dashing : bool = false
var can_dash : bool = true
var is_attacking : bool = false
var can_dash_air : bool = true
var dash_from_wall : bool = false
var direction : float = 0.0
var falling : bool = false
var can_down : bool = true
var camera_limit_set : bool = false




func _process(_delta: float) -> void:
	if !camera_limit_set:
		camera_2d.limit_left = camera_left_limit
		camera_2d.limit_right = camera_right_limit
		camera_2d.limit_bottom = camera_bottom_limit
		camera_2d.limit_top = camera_top_limit
		camera_limit_set = true
	
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
