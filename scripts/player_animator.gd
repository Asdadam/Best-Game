extends Node
class_name PlayerAnimator

@export var player: Player_Controller
@export var animated_sprite: AnimatedSprite2D
@export var first_attack: AnimationPlayer
@export var second_attack: AnimationPlayer

@onready var combat_manager: Node2D = $"../CombatManager"


func _ready() -> void:
	first_attack.animation_finished.connect(_on_animation_finished)
	second_attack.animation_finished.connect(_on_animation_finished)

func _process(_delta: float) -> void:
	#OYUNCU SALDIRMIYORKEN OYUNCU ANİMASYONLARINI YÖNET
	if not player.is_attacking:
		update_movement_animation()

func update_movement_animation() -> void:
	if player.dashing:
		animated_sprite.play("dash")
		return

	#KARAKTER ANİMASYONLARI
	if player.is_on_floor():
		if player.direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		if player.velocity.y > 0:
			animated_sprite.play("falling")
		elif player.velocity.y < 0:
			animated_sprite.play("jumping")

func play_attack(combo_index: int) -> void:
	if combo_index == 0:
		first_attack.play("attack")
		animated_sprite.play("attack")
	elif combo_index == 1:
		second_attack.play("secondAttack")
		animated_sprite.play("2Attack")

func stop_attack() -> void:
	first_attack.stop()
	second_attack.stop()

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack" or anim_name == "secondAttack":
		combat_manager.finish_attack()
