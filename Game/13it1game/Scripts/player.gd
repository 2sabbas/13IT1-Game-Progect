extends CharacterBody2D

@export var speed = 125
var cur_dir = "none"


func _ready() -> void:
	add_to_group("player")


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
	else:
		velocity = Vector2.ZERO

	move_and_slide()
