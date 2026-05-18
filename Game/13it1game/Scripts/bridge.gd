extends StaticBody2D

@onready var label: Label = $Label


var selected = false

func _ready() -> void:
	add_to_group("object")

func _process(delta: float) -> void:
	label.visible = selected
	print(selected)
	
	
