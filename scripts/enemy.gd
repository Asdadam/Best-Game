extends CharacterBody2D

@export_category("Stats")

@export var hit_points : int = 50
@onready var hp: Label = $HP
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	hp.text = str(hit_points)
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)

func _process(_delta: float) -> void:
	if hit_points <= 0:
		animated_sprite_2d.play("Death")
	hp.text = str(hit_points)


func take_damage(damage_taken : int):
	hit_points -= damage_taken

func _on_animation_finished():
	if animated_sprite_2d.animation == "Death":
		death()

func death():
	queue_free()
