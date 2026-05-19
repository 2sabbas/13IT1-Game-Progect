extends Node2D

@onready var selection_area: Area2D = $"Selection Area"
@onready var collision_shape_2d: CollisionShape2D = $"Selection Area/CollisionShape2D"


var selectionStartPoint = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if (selectionStartPoint == Vector2.ZERO && event is InputEventMouseButton && event.button_index == 1 && event.is_pressed()):
		selectionStartPoint = get_global_mouse_position()
	elif (selectionStartPoint != Vector2.ZERO && event is InputEventMouseButton && event.button_index == 1):
		_select_objects()
		selectionStartPoint = Vector2.ZERO

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if selectionStartPoint == Vector2.ZERO: return
	
	var mousePosition = get_global_mouse_position()
	var startX = selectionStartPoint.x
	var startY = selectionStartPoint.y
	var endX = mousePosition.x
	var endY = mousePosition.y
	
	var lineWidth = 0.5
	var lineColor = Color.WHITE
	
	draw_line(Vector2(startX, startY), Vector2(endX, startY), lineColor, lineWidth)
	draw_line(Vector2(startX, startY), Vector2(startX, endY), lineColor, lineWidth)
	draw_line(Vector2(endX, startY), Vector2(endX, endY), lineColor, lineWidth)
	draw_line(Vector2(startX, endY), Vector2(endX, endY), lineColor, lineWidth)

func _select_objects():
	var size = abs(get_global_mouse_position() - selectionStartPoint)
	var areaPosition = get_rect_start_position()
	
	selection_area.global_position = areaPosition
	collision_shape_2d.position = size / 2
	collision_shape_2d.shape.size = size
	
	await get_tree().create_timer(0.02).timeout
	
	var objects = get_tree().get_nodes_in_group("object")
	
	for body in selection_area.get_overlapping_areas():
		
		if body.get_parent().is_in_group("object"):
			body.get_parent().selected = true
			objects.erase(body.get_parent())
	
	for body in objects:
		body.selected = false

func get_rect_start_position():
	var newPosition = Vector2.ZERO
	var mousePosition = get_global_mouse_position()
	
	if selectionStartPoint.x < mousePosition.x:
		newPosition.x = selectionStartPoint.x
	else: newPosition.x = mousePosition.x
	
	if selectionStartPoint.y < mousePosition.y:
		newPosition.y = selectionStartPoint.y
	else: newPosition.y = mousePosition.y
	
	return newPosition
