extends Area2D

var player: CharacterBody2D = null
var player_on_water := false

@onready var water_layer: TileMapLayer = $"../Water"
@onready var bridge_detector: TileMapLayer = $"../Bridge Detector"


func _ready() -> void:
	build_water_collision()


func build_water_collision():
	for cell in water_layer.get_used_cells():
		var collision := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(16, 16)
		collision.shape = shape
		collision.position = water_layer.map_to_local(cell)
		add_child(collision)


func _physics_process(delta: float) -> void:
	if player == null:
		return

	var cell = water_layer.local_to_map(
		water_layer.to_local(player.global_position)
	)

	# No bridge under the player
	if bridge_detector.get_cell_source_id(cell) == -1:
		get_tree().reload_current_scene()


func _on_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	player = body as CharacterBody2D
	player_on_water = true


func _on_body_exited(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	player = null
	player_on_water = false
