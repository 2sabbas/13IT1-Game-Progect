extends StaticBody2D

@onready var label: Label = $Label


var selected = false

func _ready() -> void:
	add_to_group("object")

func _process(delta: float) -> void:
	label.visible = selected
	

func _on_selectable_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.set_collision_mask_value(2, false)
		print("yes")


func _on_selectable_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.set_collision_mask_value(2, true)
		print("no")
