extends Control

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


func _process(delta: float) -> void:
	copies_available.text = "Copies Available: " + str(Global.num_of_copies_available)
	undos_available.text = "Undos Available: " + str(Global.num_of_undos_available)
	cuts_available.text = "Cuts available: " + str(Global.num_of_cuts_available)
	paste__available.text = "Paste available: " + str(Global.paste_available)
	selected.text = "Selected: " + str(Global.selected)
	
	copy_icon.modulate
	
	selected_icon.frame = 6 if Global.selected else 5
	
