extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var speed = 80
var cur_dir = "none"

@onready var water_layer: TileMapLayer = $"../Map/Water"
@onready var bridge_detector: TileMapLayer = $"../Map/Bridge Detector"

func _ready() -> void:
	add_to_group("Player")


func _physics_process(delta: float) -> void:
	player_moment(delta)

	if move_and_slide():
		resolve_collision()

	check_water()


func resolve_collision():
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var body := collision.get_collider() as MovableObject
		if body:
			body.apply_impact(velocity)


func check_water() -> void:
	var cell = water_layer.local_to_map(
		water_layer.to_local(global_position)
	)

	# Not standing on water
	if water_layer.get_cell_source_id(cell) == -1:
		return

	# Standing on water without a bridge
	if bridge_detector.get_cell_source_id(cell) == -1:
		get_tree().reload_current_scene()


func player_moment(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input_dir: #if input-dir != Vecter2.ZERO
		velocity = input_dir * speed

		# Prefer X direction for diagonal movement
		if input_dir.x != 0:
			if input_dir.x > 0:
				cur_dir = "right"
			else:
				cur_dir = "left"
		elif input_dir.y != 0:
			if input_dir.y > 0:
				cur_dir = "down"
			else:
				cur_dir = "up"
		play_movement_animation(1)
	else:
		velocity = Vector2.ZERO
		play_movement_animation(0)


func play_movement_animation(motion):
	var dir = cur_dir
	
	if dir == "right":
		animated_sprite.flip_h = false
		if motion == 1:
			animated_sprite.play("walk_side")
		else:
			animated_sprite.play("idle_side")
	if dir == "left":
		animated_sprite.flip_h = true
		if motion == 1:
			animated_sprite.play("walk_side")
		else:
			animated_sprite.play("idle_side")
	if dir == "up":
		animated_sprite.flip_h = false
		if motion == 1:
			animated_sprite.play("walk_up")
		else:
			animated_sprite.play("idle_up")
	if dir == "down":
		animated_sprite.flip_h = false
		if motion == 1:
			animated_sprite.play("walk_down")
		else:
			animated_sprite.play("idle_down")
