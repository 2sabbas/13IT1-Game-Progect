extends Area2D

@onready var sprite: Sprite2D = $Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if !self.get_overlapping_bodies().is_empty():
		sprite.frame = 2


func _on_body_exited(body: Node2D) -> void:
	if self.get_overlapping_bodies().is_empty():
		sprite.frame = 0
