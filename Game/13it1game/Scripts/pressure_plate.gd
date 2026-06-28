extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

@export var gate_sprite: Sprite2D
@export var gate_collision_shape: CollisionShape2D



func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if !self.get_overlapping_bodies().is_empty():
		sprite.frame = 2
		gate_sprite.frame = 1
		gate_collision_shape.set_deferred("disabled", true)


func _on_body_exited(body: Node2D) -> void:
	if self.get_overlapping_bodies().is_empty():
		sprite.frame = 0
		gate_sprite.frame = 0
		gate_collision_shape.set_deferred("disabled", false)
