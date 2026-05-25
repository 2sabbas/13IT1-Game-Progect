extends Node2D

@onready var selection_area: Area2D = $"Selection Area"
@onready var collision_shape_2d: CollisionShape2D = $"Selection Area/CollisionShape2D"


var selectionStartPoint = Vector2.ZERO
var clipboard: Array = []

func _input(event: InputEvent) -> void:
	if (selectionStartPoint == Vector2.ZERO && Input.is_action_pressed("left_click")):
		selectionStartPoint = get_global_mouse_position()
	elif (selectionStartPoint != Vector2.ZERO && Input.is_action_just_released("left_click")):
		select_objects()
		selectionStartPoint = Vector2.ZERO
	
	# Copy
	if Input.is_action_pressed("copy"):
		copy_selected()
	# Paste
	if Input.is_action_pressed("paste"):
		paste_objects()
	

func copy_selected():
	clipboard.clear()
	var selectedObjects = get_tree().get_nodes_in_group("Object").filter(func(o): return o.selected)
	
	if selectedObjects.is_empty():
		return
	
	# find the center of all selected objects so pasting is relative
	var center = Vector2.ZERO
	for obj in selectedObjects:
		center += obj.global_position
	center /= selectedObjects.size()
	
	for obj in selectedObjects:    #this saves a dictonary of the object;s file path and its offset to the center
		clipboard.append({
			"scene": obj.scene_file_path,
			"offset": obj.global_position - center 
		})
	print("Copied ", clipboard.size(), " object(s)")

func paste_objects():
	if clipboard.is_empty():
		return
	
	var centerOfPaste = get_global_mouse_position()
	
	for item in clipboard:
		var packedScene = load(item["scene"]) as PackedScene
		var newObj = packedScene.instantiate()
		newObj.position = get_parent().to_local(centerOfPaste + item["offset"])
		get_parent().move_child(newObj, 1)  #change the order in the scene tree to the index
		get_parent().get_node("Bridges").add_child(newObj)
		
		clipboard.clear()	
	print("Pasted ", clipboard.size(), " object(s)")

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

func select_objects():
	var size = abs(get_global_mouse_position() - selectionStartPoint)
	var areaPosition = get_rect_start_position()
	
	selection_area.global_position = areaPosition
	collision_shape_2d.position = size / 2
	collision_shape_2d.shape.size = size
	
	await get_tree().create_timer(0.02).timeout
	
	var objects = get_tree().get_nodes_in_group("Object")
	
	for body in selection_area.get_overlapping_areas():
		
		if body.get_parent().is_in_group("Object"):
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
