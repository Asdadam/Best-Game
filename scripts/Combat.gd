extends Node2D

@onready var combo_timer: Timer = $combo_timer
@onready var player: Player_Controller = $".."
@onready var animator: PlayerAnimator = $"../PlayerAnimator"
@onready var hit_box: Area2D = $"../Pivot/HitBox"


var attack_count : int = 0

func _ready() -> void:
	combo_timer.timeout.connect(_on_combo_finished)

func _process(_delta: float) -> void:
	start_attack()


func start_attack() -> void:
	if Input.is_action_just_pressed("attack") and not player.is_attacking and not player.is_on_wall() and not player.dashing:
		player.is_attacking = true
		combo_timer.stop()
		attack()
		attack_count = (attack_count + 1) % 2

func attack():
	animator.play_attack(attack_count)

func finish_attack() -> void:
	player.is_attacking = false
	combo_timer.start()


func _on_combo_finished() -> void:
	attack_count = 0
