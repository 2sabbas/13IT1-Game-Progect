extends Area2D

var player_close = false

@onready var label: Label = $PanelContainer/Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var markers: Array[Marker2D]

var instruction_counter = 0

var instructions: Array = [
	"Use WASD to move", 
	"Make it to the end of the map   --->", 
	"You need to get accross the water", 
	"Go up and get the copy pickup", 
	"Now loog at your copy counter, it has gone up, meaning you can now copy an object once", 
	"You can now make your way back to the bridge from before", 
	"you can use your mouse to drag select the bridge and press Ctrl + C to copy it", 
	"After you have copied the bridge, you can move your mouse to the water you need to cross and press Ctrl + V to paste it", 
]


func _ready() -> void:
	global_position = markers[0].global_position
	label.text = instructions[0]
	
	animation_player.play("Fade_out_label")
	


func _process(delta: float) -> void:
	if player_close and Input.is_action_just_pressed("enter"):
		next_instruction()


func next_instruction():
	if instruction_counter >= instructions.size() - 1:
		return
	
	instruction_counter += 1
	
	global_position = markers[instruction_counter].global_position
	label.text = instructions[instruction_counter]


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_close = true
		animation_player.play("Fade_in_label")


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_close = false
		animation_player.play("Fade_out_label")
		
