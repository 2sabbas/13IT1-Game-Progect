extends Area2D

enum Type {Empty, Copy, Cut, Undo}
@export var collectable_type: Type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#if collectable_type == Copy:
		pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
