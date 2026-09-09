extends Node


@onready var music_player: AudioStreamPlayer = $AudioStreamPlayer

var placeholder = preload("res://assets/music/Placeholder.mp3")
var medieval_bg = preload("res://assets/music/Medieval_BG.mp3")
var medieval_kale = preload("res://assets/music/Medieval_Kale.mp3")

func play_music(music_stream: AudioStream) -> void:
	if music_player.stream == music_stream and music_player.playing: # Müzik zaten çalıyorsa tekrar başlama.
		return
	
	music_player.stream = music_stream
	music_player.play()

func stop_music() -> void:
	music_player.stop()
