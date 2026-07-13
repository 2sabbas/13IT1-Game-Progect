extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.current_game_state = Global.Game_State.Main_Menu


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_tutorial_button_up() -> void:
	Global.current_game_state = Global.Game_State.Playing_Tutorial
	get_tree().change_scene_to_file("res://Scenes/tutorial_map.tscn")
	


func _on_play_world_button_up() -> void:
	Global.current_game_state = Global.Game_State.Playing_World
	get_tree().change_scene_to_file("res://Scenes/world_map.tscn")


func _on_controls_button_up() -> void:
	Global.current_game_state = Global.Game_State.Controls
	get_tree().change_scene_to_file("res://Scenes/controls.tscn")


func _on_quit_button_up() -> void:
	get_tree().quit()
