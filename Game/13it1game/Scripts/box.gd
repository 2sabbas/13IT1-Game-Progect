class_name MovableObject
extends CharacterBody2D

@export_range(0.0, 1.0) var drag := 0.5


func _physics_process(_delta: float) -> void:
	if velocity.length_squared() > 1.0:
		velocity *= 1.0 - drag
		if move_and_slide():
			resolve_collisions()


func resolve_collisions() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var body := collision.get_collider() as MovableObject
		if body:
			body.apply_impact(velocity)
		else:
			velocity -= velocity.project(collision.get_normal())


func apply_impact(impact_velocity: Vector2) -> void:
	velocity = impact_velocity
