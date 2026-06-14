extends Node2D

@onready var tile_layers: Array = []
var layers_to_copy = ["Objects"]

var selection_start_point = Vector2.ZERO
var selection_end_point = Vector2.ZERO
var is_selecting = false
var has_selected = false
var clipboard: Array = []
var undo_history: Array = []


func _ready() -> void:
	var map = get_parent().get_node("Map")
	for child in map.get_children():
		if child is TileMapLayer and child.name in layers_to_copy:
			tile_layers.append(child)


func _input(event: InputEvent) -> void:
	# start new selection on click - also clears any existing selection
	if (Input.is_action_just_pressed("left_click")):
		selection_start_point = get_global_mouse_position()
		selection_end_point = selection_start_point
		is_selecting = true
		has_selected = false
	# mouse released - freeze the box in place
	else:
		if (Input.is_action_just_released("left_click")):
			selection_end_point = get_global_mouse_position()
			is_selecting = false
			if (selection_start_point.distance_to(selection_end_point) > 8):
				has_selected = true
			else:
				selection_start_point = Vector2.ZERO
				selection_end_point = Vector2.ZERO
	
	# Copy
	if Input.is_action_just_pressed("copy") && has_selected && Global.num_of_copies_available > 0:
		copy_selected()
		selection_start_point = Vector2.ZERO
		selection_end_point = Vector2.ZERO
		is_selecting = false
		has_selected = false
		Global.num_of_copies_available -= 1
		
	# Paste
	if Input.is_action_just_pressed("paste"):
		paste_objects()
	
	if Input.is_action_just_pressed("undo") && Global.num_of_undos_available > 0:
		undo()
	


func _process(delta: float) -> void:
	queue_redraw()


func copy_selected():
	clipboard.clear()
	var mouse_position = get_global_mouse_position()
	var top_left = Vector2(
		min(selection_start_point.x, selection_end_point.x), 
		min(selection_start_point.y, selection_end_point.y)
	)
	var bottom_right = Vector2(
		max(selection_start_point.x, selection_end_point.x), 
		max(selection_start_point.y, selection_end_point.y)
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
	var snapshot: Array = []
	
	for item in clipboard:
		var layer = item["layer"]
		var paste_origin = layer.local_to_map(layer.to_local(mouse_position))
		var target_cell = paste_origin + item["offset"]
		
		snapshot.append({
			"layer": layer, 
			"cell": target_cell, 
			"source_id": layer.get_cell_source_id(target_cell), 
			"atlas_coords": layer.get_cell_atlas_coords(target_cell),
			"alternative": layer.get_cell_alternative_tile(target_cell)
		})
		
		layer.set_cell(target_cell, item["source_id"], item["atlas_coords"], item["alternative"])
	
	undo_history.append({
		"snapshot": snapshot, 
		"clipboard": clipboard.duplicate(true), #makes a copy of clipboard so when the clipboard is cleared, the undo history still has a copy of the action that happened
	})
	
	print("Pasted ", clipboard.size(), " tiles")
	clipboard.clear()	


func undo():
	if undo_history.is_empty(): 
		print("Nothing to undo")
		return
	if Global.num_of_undos_available == 0: return
	
	var last_action = undo_history.pop_back()
	
	for tile in last_action["snapshot"]:
		var layer = tile["layer"]
		if tile["source_id"] == -1:
			layer.erase_cell(tile["cell"])
		else:
			layer.set_cell(tile["cell"], tile["source_id"], tile["atlas_coords"], tile["alternative"])
	
	clipboard = last_action["clipboard"]
	Global.num_of_copies_available += 1
	Global.num_of_undos_available -= 1
	
	print("Undo complete, copies restored: ", Global.num_of_copies_available)


func _draw() -> void:
	if selection_start_point == Vector2.ZERO: return
	
	var start = to_local(selection_start_point)
	var end = to_local(selection_end_point if not is_selecting else get_global_mouse_position())
	
	var lineWidth = 0.5
	var lineColor = Color.YELLOW if has_selected else Color.WHITE
	var fillColor = Color(1, 1, 0, 0.15) if has_selected else Color(1, 1, 1, 0.15)
	
	draw_rect(Rect2(start, end - start), fillColor)
	draw_line(Vector2(start.x, start.y), Vector2(end.x, start.y), lineColor, lineWidth)
	draw_line(Vector2(start.x, start.y), Vector2(start.x, end.y), lineColor, lineWidth)
	draw_line(Vector2(end.x, start.y), Vector2(end.x, end.y), lineColor, lineWidth)
	draw_line(Vector2(start.x, end.y), Vector2(end.x, end.y), lineColor, lineWidth)
