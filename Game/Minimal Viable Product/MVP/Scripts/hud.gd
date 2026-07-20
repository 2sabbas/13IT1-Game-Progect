extends Control

@onready var copies_avalable: Label = $"Copies Avalable"

func _ready() -> void:
	copies_avalable.text = "Copies Avalable: " + str(Global.numOfCopiesAvalable)


func _process(delta: float) -> void:
	copies_avalable.text = "Copies Avalable: " + str(Global.numOfCopiesAvalable)
