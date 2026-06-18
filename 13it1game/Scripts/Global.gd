extends Node2D

var num_of_copies_available = 0
var num_of_undos_available = 0
var num_of_cuts_available = 0


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
