extends CharacterBody2D

class_name Player_Controller


@onready var combat_manager: Node2D = $CombatManager
@onready var dash_duration: Timer = $MovementManager/Dash_duration
@onready var hit_box: Area2D = $Pivot/HitBox
@onready var pivot: Node2D = $Pivot
@onready var dash_cd: Timer = $MovementManager/Dash_cd
@onready var animator: PlayerAnimator = $PlayerAnimator # Yeni animasyon düğümü
@onready var down_cd: Timer = $MovementManager/Down_cd


var dashing : bool = false
var can_dash : bool = true
var is_attacking : bool = false
var can_dash_air : bool = true
var dash_from_wall : bool = false
var direction : float = 0.0
var falling : bool = false
var can_down : bool = true


func _process(_delta: float) -> void:
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
