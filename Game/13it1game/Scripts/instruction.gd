extends Area2D

var player_close = false

@onready var label: Label = $PanelContainer/Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var markers: Array[Marker2D]

var jump_1 = false
var jump_2 = false
var jump_3 = false
var jump_4 = false

var instruction_counter = 0

var instructions: Array = [
	# Intro (3)
	"Welcome to COMMAND LINE. Press Enter to continue.",
	"In COMMAND LINE, you solve puzzles using keyboard shortcuts.",
	"This tutorial will teach you the basic core mechanics of COMMAND LINE.",

	# Puzzle 1 - Copy (7)
	"You need to cross the water.",
	"Collect the Copy Charge ahead.",
	"Your Copy counter has increased. You can now copy one object.",
	"Press O to toggle editable outlines.",
	"Drag-select the bridge and press Ctrl + C to copy it. Press p to toggle paste preview",
	"Move your mouse over the water and press Ctrl + V to paste the bridge. Press Ctrl + R to reset if you make a mistake.",
	"Cross the bridge you created.",

	# Puzzle 2 - Undo (8)
	"Repeat what you did in the previous puzzle.",
	"You've used your only Copy Charge.",
	"Collect the Undo Charge there.",
	"Undo lets you reverse your last action and restores the command you used.",
	"Press Ctrl + Z to undo your previous paste.",
	"After using the Undo Charge, your Copy Charge has been restored.",
	"Copy the bridge again and paste it across the next gap.",
	"Cross the new bridge.",

	# Puzzle 3 - Cut (4)
	"A wall is blocking your path.",
	"Collect the Cut Charge.",
	"Drag-select part of the wall and press Ctrl + X to remove it.",
	"Walk through the opening you created.",

	# Puzzle 4 - Pressure Plate (3)
	"The gate ahead is locked.",
	"Push the box onto the pressure plate to keep the gate open.",
	"Walk through the open gate.",

	# Finish (2)
	"Tutorial complete! You now know the basics of COMMAND LINE.",
	"Enter the portal to complete the tutorial."
]


func _ready() -> void:
	global_position = markers[0].global_position
	Global.instruction_message = instructions[0]
	print(instructions.size())
	
	


func _process(delta: float) -> void:
	if player_close and Input.is_action_just_pressed("enter"):
		next_instruction()


func next_instruction():
	if instruction_counter >= instructions.size() - 1 || instruction_counter >= markers.size() - 1:
		return
	
	instruction_counter += 1
	global_position = markers[instruction_counter].global_position
	Global.instruction_message = instructions[instruction_counter]


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_close = true
		Global.instruction_visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_close = false
		Global.instruction_visible = false
		

##These set of bofy_entered functions set the instruction counter variable to the last number in the specific area and then use the next_instruction function
func _on_jump_1_body_entered(body: Node2D) -> void:
	if !jump_1 && body.is_in_group("Player"):
		jump_1 = true
		instruction_counter = 10 -1
		next_instruction()


func _on_jump_2_body_entered(body: Node2D) -> void:
	if !jump_2 && body.is_in_group("Player"):
		jump_2 = true
		instruction_counter = 18 -1
		next_instruction()


func _on_jump_3_body_entered(body: Node2D) -> void:
	if !jump_3 && body.is_in_group("Player"):
		jump_3 = true
		instruction_counter = 22 -1
		next_instruction()


func _on_jump_4_body_entered(body: Node2D) -> void:
	if !jump_4 && body.is_in_group("Player"):
		jump_4 = true
		instruction_counter = 25 -1
		next_instruction()
