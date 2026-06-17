extends Area2D

enum Collectable_Type {Empty, Copy, Cut, Undo}
@export var type: Collectable_Type

@onready var pickup: Sprite2D = $Pickup
@onready var point_light_2d: PointLight2D = $PointLight2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if type == Collectable_Type.Empty:
		pickup.modulate = Color.WHITE
		point_light_2d.color = Color.WHITE
	elif type == Collectable_Type.Copy:
		pickup.modulate = Color.CYAN
		point_light_2d.color = Color.CYAN
	elif type == Collectable_Type.Cut:
		pickup.modulate = Color.YELLOW
		point_light_2d.color = Color.YELLOW
	elif type == Collectable_Type.Undo:
		pickup.modulate = Color.MAGENTA
		point_light_2d.color = Color.MAGENTA
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if type == Collectable_Type.Copy: Global.num_of_copies_available += 1
		if type == Collectable_Type.Cut: Global.num_of_cuts_available += 1
		if type == Collectable_Type.Undo: Global.num_of_undos_available += 1
		
		queue_free()
