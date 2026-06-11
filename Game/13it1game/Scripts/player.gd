extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var speed = 125
var cur_dir = "none"


func _ready() -> void:
	add_to_group("Player")


func _physics_process(delta: float) -> void:
	player_moment(delta)


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

	move_and_slide()


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
			animated_sprite.play("walk_back")
		else:
			animated_sprite.play("idle_back")
	if dir == "down":
		animated_sprite.flip_h = false
		if motion == 1:
			animated_sprite.play("walk_front")
		else:
			animated_sprite.play("idle_front")
