extends Node


@export_file("*.tscn") var destination_scene_file : String
@export var transition_area : Area2D

var transitioning : bool = false

func _ready() -> void:
	if transition_area:
		transition_area.body_entered.connect(_on_transition)
	else:
		push_warning("No transitioning Area")
		return
	
	
func _on_transition(body) -> void:
	if Transitioner.get_node_or_null("ColorRect") and not transitioning:
		if body.is_in_group("Player"):
			transitioning = true
			Transitioner.get_node_or_null("ColorRect").change_scene(destination_scene_file)
