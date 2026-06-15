extends Control

@onready var copies_available: Label = $"Copies Available"
@onready var undos_available: Label = $"Undos Available"

func _ready() -> void:
	copies_available.text = "Copies Available: " + str(Global.num_of_copies_available)
	undos_available.text = "Undos Available: " + str(Global.num_of_undos_available)


func _process(delta: float) -> void:
	copies_available.text = "Copies Available: " + str(Global.num_of_copies_available)
	undos_available.text = "Undos Available: " + str(Global.num_of_undos_available)
