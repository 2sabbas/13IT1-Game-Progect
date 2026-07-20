extends Control

@onready var controls_animation_player: AnimationPlayer = $ControlsAnimationPlayer

@onready var instruction_animation_player: AnimationPlayer = $InstructionAnimationPlayer
@onready var instructions: Label = $Instructions


#Labels
@onready var copies_available: Label = $"Copies Available"
@onready var undos_available: Label = $"Undos Available"
@onready var cuts_available: Label = $"Cuts Available"
@onready var paste__available: Label = $"Paste  Available"
@onready var selected: Label = $Selected

#Icons
@onready var copy_icon: Sprite2D = $"Copy Icon"
@onready var cut_icon: Sprite2D = $"Cut Icon"
@onready var undo_icon: Sprite2D = $"Undo Icon"
@onready var paste_icon: Sprite2D = $"Paste Icon"
@onready var selected_icon: Sprite2D = $"Selected Icon"

func _ready() -> void:
	pass


var temp_instruction_visible = Global.instruction_visible

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("help"):
		controls_animation_player.play("RESET")
	if Input.is_action_just_released("help"):
		controls_animation_player.play("Fade_out_controls")
	
	
	copies_available.text = str(Global.num_of_copies_available)
	undos_available.text = str(Global.num_of_undos_available)
	cuts_available.text = str(Global.num_of_cuts_available)
	paste__available.text = str(Global.paste_available)
	selected.text = "Selected: " + str(Global.selected)
	
	#copy_icon.modulate
	selected_icon.frame = 6 if Global.selected else 5
	
	instructions.text = Global.instruction_message
	if temp_instruction_visible != Global.instruction_visible:
		instruction_animation_player.play("Fade_instruction_in") if Global.instruction_visible else instruction_animation_player.play("Fade_instruction_out")
		temp_instruction_visible = Global.instruction_visible
	
