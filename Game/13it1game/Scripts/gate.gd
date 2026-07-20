extends StaticBody2D

var opened = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	collision_shape.disabled = opened
	if !opened:
		sprite.frame = 0
	else:
		sprite.frame = 1
