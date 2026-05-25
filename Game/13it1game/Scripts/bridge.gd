extends StaticBody2D

@onready var label: Label = $Label


var selected = false

func _ready() -> void:
	add_to_group("Object")

func _process(delta: float) -> void:
	label.visible = selected
	

func _on_selectable_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.set_collision_mask_value(2, false)


func _on_selectable_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.set_collision_mask_value(2, true)
