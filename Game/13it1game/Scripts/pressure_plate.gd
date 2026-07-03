extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

@export var Gate: StaticBody2D



func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if !self.get_overlapping_bodies().is_empty():
		sprite.frame = 2
		Gate.opened = true


func _on_body_exited(body: Node2D) -> void:
	if self.get_overlapping_bodies().is_empty():
		sprite.frame = 0
		Gate.opened = false
