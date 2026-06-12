extends Control

@onready var copies_available: Label = $"Copies Available"

func _ready() -> void:
	copies_available.text = "Copies Available: " + str(Global.num_of_copies_available)


func _process(delta: float) -> void:
	copies_available.text = "Copies Available: " + str(Global.num_of_copies_available)
