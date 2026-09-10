extends Node

var score = 0
var typing: String = "" # Hile kodu gibi yazılar yazmak için.
var curr_scene_file_path : String = ""
var largest_mode : int = 0




func _process(_delta: float) -> void:
	if curr_scene_file_path == "":
		curr_scene_file_path = get_tree().current_scene.scene_file_path

func _ready() -> void:
	AudioManager.play_music(AudioManager.medieval_bg)
	var dev_modes = ["rel", "test", "main"]
	for i in dev_modes:
		if i.length() > largest_mode:
			largest_mode = i.length()


func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		typing += event.as_text().to_lower()
		
		# Son x karakteri tutup hafıza dolumunu engelliyor.
		if typing.length() > largest_mode:
			typing = typing.right(largest_mode)
			
		if typing.ends_with("main") and curr_scene_file_path != "res://scenes/game.tscn":
			typing = ""
			Transitioner.get_child(0).change_scene("res://scenes/game.tscn")
			curr_scene_file_path = "res://scenes/game.tscn"
		if typing.ends_with("test") and curr_scene_file_path != "res://levels/test_level.tscn":
			typing = ""
			Transitioner.get_child(0).change_scene("res://levels/test_level.tscn")
			curr_scene_file_path = "res://levels/test_level.tscn"
		if typing.ends_with("rel"):
			typing = ""
			Transitioner.get_child(0).change_scene(curr_scene_file_path)
