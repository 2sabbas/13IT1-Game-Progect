extends Node2D

@onready var tile_layers: Array = []
var layers_to_copy = ["Hitbox Elements"]

var selection_start_point = Vector2.ZERO
var clipboard: Array = []


func _ready() -> void:
	var map = get_parent().get_node("Map")
	for child in map.get_children():
		if child is TileMapLayer and child.name in layers_to_copy:
			tile_layers.append(child)


func _input(event: InputEvent) -> void:
	if (selection_start_point == Vector2.ZERO && Input.is_action_pressed("left_click")):
		selection_start_point = get_global_mouse_position()
	elif (selection_start_point != Vector2.ZERO && Input.is_action_just_released("left_click")):
		selection_start_point = Vector2.ZERO
	
	# Copy
	if (Input.is_action_just_pressed("copy") && Global.numOfCopiesAvalable > 0):
		copy_selected()
		#copy_selected()
		Global.numOfCopiesAvalable -= 1
		
	# Paste
	if Input.is_action_just_pressed("paste"):
		paste_objects()
	


func _process(delta: float) -> void:
	queue_redraw()
	#print("clipboard enpty: " + str(clipboard.is_empty()))


func copy_selected():
	clipboard.clear()
	var mouse_position = get_global_mouse_position()
	var top_left = Vector2(
		min(selection_start_point.x, mouse_position.x), 
		min(selection_start_point.y, mouse_position.y)
	)
	var bottom_right = Vector2(
		max(selection_start_point.x, mouse_position.x), 
		max(selection_start_point.y, mouse_position.y)
	)
	var start_cell = Vector2i.ZERO
	var end_cell = Vector2i.ZERO
	
	for layer in tile_layers:
		start_cell = layer.local_to_map(layer.to_local(top_left))
		end_cell = layer.local_to_map(layer.to_local(bottom_right))
		var layer_clipboard: Array = []
		
		for x in range(start_cell.x, end_cell.x + 1):
			for y in range(start_cell.y, end_cell.y +1):
				var cell = Vector2i(x, y)
				var source_id = layer.get_cell_source_id(cell)
				
				if source_id == -1:
					continue  #skip the rest of the loop if the cell is empty
				
				layer_clipboard.append({
					"layer": layer, 
					"offset": cell - start_cell, 
					"source_id": source_id, 
					"atlas_coords": layer.get_cell_atlas_coords(cell),
					"alternative": layer.get_cell_alternative_tile(cell)
				})
		var center_cell = (start_cell + end_cell) / 2
		for item in layer_clipboard:
			item["offset"] = item["offset"] - (center_cell - start_cell)
		clipboard.append_array(layer_clipboard)
		
	print("Copied ", clipboard.size(), " tiles")


func paste_objects():
	if clipboard.is_empty(): return
	
	var mouse_position = get_global_mouse_position()
	
	for item in clipboard:
		var layer = item["layer"]
		var paste_origin = layer.local_to_map(layer.to_local(mouse_position))
		var target_cell = paste_origin + item["offset"]
		
		layer.set_cell(target_cell, item["source_id"], item["atlas_coords"], item["alternative"])
	
	print("Pasted ", clipboard.size(), " tiles")
	clipboard.clear()	


func _draw() -> void:
	if selection_start_point == Vector2.ZERO: return
	
	var mouse_position = get_global_mouse_position()
	var start = to_local(selection_start_point)
	var end = to_local(mouse_position)
	
	var lineWidth = 0.5
	var lineColor = Color.WHITE
	var fillColor = Color(1, 1, 1, 0.15)
	
	draw_rect(Rect2(start, end - start), fillColor)
	draw_line(Vector2(start.x, start.y), Vector2(end.x, start.y), lineColor, lineWidth)
	draw_line(Vector2(start.x, start.y), Vector2(start.x, end.y), lineColor, lineWidth)
	draw_line(Vector2(end.x, start.y), Vector2(end.x, end.y), lineColor, lineWidth)
	draw_line(Vector2(start.x, end.y), Vector2(end.x, end.y), lineColor, lineWidth)


func get_rect_start_position():
	var newPosition = Vector2.ZERO
	var mouse_position = get_global_mouse_position()
	
	if selection_start_point.x < mouse_position.x:
		newPosition.x = selection_start_point.x
	else: newPosition.x = mouse_position.x
	
	if selection_start_point.y < mouse_position.y:
		newPosition.y = selection_start_point.y
	else: newPosition.y = mouse_position.y
	
	return newPosition
