extends ColorRect

@onready var color_rect: ColorRect = $"."


func change_scene(destination_scene : String) -> void:
	var fade_in : Tween = create_tween()
	fade_in.tween_property(color_rect, "modulate:a", 1, 0.5)
	await fade_in.finished
	get_tree().change_scene_to_file(destination_scene)
	
	var fade_out : Tween = create_tween()
	fade_out.tween_property(color_rect, "modulate:a", 0, 0.5)
	await fade_out.finished
