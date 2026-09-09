extends Node

var score = 0
var typing: String = "" # Hile kodu gibi yazılar yazmak için.

@onready var score_label: Label = $ScoreLabel

func add_point():
	score += 1
	score_label.text = "You Collected " + str(score) + " coins."

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		typing += event.as_text().to_lower()
		
		# Son x karakteri tutup hafıza dolumunu engelliyor.
		if typing.length() > 5:
			typing = typing.right(5)
		
		if typing.ends_with("test"):
			typing = ""
			get_tree().change_scene_to_file("res://scenes/test_level.tscn")

func _ready() -> void:
	AudioManager.play_music(AudioManager.medieval_bg)
