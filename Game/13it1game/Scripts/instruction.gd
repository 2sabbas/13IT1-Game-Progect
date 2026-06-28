extends Area2D

var player_close = false

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $Label/AnimationPlayer

var instruction_counter = 0
var instruction: Array = [
	"One", 
	"Two", 
]


func _ready() -> void:
	if player_close == false:
		animation_player.play("Fade_out_label")
	


func _process(delta: float) -> void:
	if player_close && Input.is_action_just_pressed("enter"):
		if instruction_counter < (instruction.size() - 1):
			position = Vector2(200,200)      # Call the next_in_group() method or something to go to the next marker 2D to get the next position
			instruction_counter += 1
	label.text = instruction[instruction_counter]


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_close = true
		animation_player.play("Fade_in_label")


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_close = false
		animation_player.play("Fade_out_label")
		
