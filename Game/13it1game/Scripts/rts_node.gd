extends Node2D

@onready var tile_layers: Array[TileMapLayer] = []
var layers_to_copy = ["Editable Regions", "Ysort Editable Regions"]
@onready var highlighted_layers: Array[TileMapLayer] = []
var highlight_layer_names = ["Highlights"]
var highlight_visible = false
const HIGHLIGHT_SOURCE_ID := 4
const TERRAIN_SET := 0
const TERRAIN := 2

var selection_start_point = Vector2.ZERO
var selection_end_point = Vector2.ZERO
var is_selecting = false
var has_selected = false
var clipboard: Array = []
var undo_history: Array = []
var copy_method = ""
var copied_size = Vector2.ZERO
var paste_preview_enabled = true


func _ready() -> void:
	Global.num_of_copies_available = Global.initial_num_of_copies_available
	Global.num_of_cuts_available = Global.initial_num_of_cuts_available
	Global.num_of_undos_available = Global.initial_num_of_undos_available
	Global.paste_available = Global.initial_paste_available
	Global.selected = Global.initial_selected
	
	var map = get_parent().get_node("Map")
	for child in map.get_children():
		if child is TileMapLayer and child.name in layers_to_copy:
			tile_layers.append(child)
		if child is TileMapLayer and child.name in highlight_layer_names:
			highlighted_layers.append(child)
	
	for layer in highlighted_layers:
		layer.visible = highlight_visible
	update_highlight()


func _input(event: InputEvent) -> void:
	# start new selection on click - also clears any existing selection
	if (event.is_action_pressed("left_click")):
		selection_start_point = get_global_mouse_position()
		selection_end_point = selection_start_point
		is_selecting = true
		has_selected = false
		Global.selected = has_selected
	# mouse released - freeze the box in place
	else:
		if (event.is_action_released("left_click")):
			selection_end_point = get_global_mouse_position()
			is_selecting = false
			if (selection_start_point.distance_to(selection_end_point) > 8):
				has_selected = true
				Global.selected = has_selected
			else:
				selection_start_point = Vector2.ZERO
				selection_end_point = Vector2.ZERO
				has_selected = false
				Global.selected = has_selected
	
	# Copy
	if Input.is_action_just_pressed("copy") && has_selected && Global.num_of_copies_available > 0:
		copy_selected()
		selection_start_point = Vector2.ZERO
		selection_end_point = Vector2.ZERO
		is_selecting = false
		has_selected = false
		Global.selected = has_selected
		copy_method = "copy"
		Global.num_of_copies_available -= 1
		Global.paste_available = !clipboard.is_empty()
	
	# Paste
	if Input.is_action_just_pressed("paste"):
		paste_objects()
		Global.paste_available = !clipboard.is_empty()
	
	#Cut
	if Input.is_action_just_pressed("cut") && has_selected && Global.num_of_cuts_available > 0:
		cut()
		selection_start_point = Vector2.ZERO
		selection_end_point = Vector2.ZERO
		is_selecting = false
		has_selected = false
		Global.selected = has_selected
		copy_method = "cut"
		Global.num_of_cuts_available -= 1
		Global.paste_available = !clipboard.is_empty()
	
	#Undo
	if Input.is_action_just_pressed("undo") && Global.num_of_undos_available > 0:
		undo()
		Global.paste_available = !clipboard.is_empty()
	
	#Reset Scene
	if Input.is_action_just_pressed("reset"):
		Global.num_of_copies_available = Global.initial_num_of_copies_available
		Global.num_of_cuts_available = Global.initial_num_of_cuts_available
		Global.num_of_undos_available = Global.initial_num_of_undos_available
		Global.paste_available = Global.initial_paste_available
		Global.selected = Global.initial_selected
		get_tree().reload_current_scene()
	
	#toggle highlight outline
	if Input.is_action_just_pressed("toggle_highlight_outline"):
		highlight_visible = !highlight_visible
		for layer in highlighted_layers:
			layer.visible = highlight_visible
	
	#toggle paste preview
	if Input.is_action_just_pressed("toggle_paste_preview"):
		paste_preview_enabled = !paste_preview_enabled


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
	copied_size = bottom_right - top_left
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
					"cell": cell, 
					"offset": cell - start_cell, 
					"source_id": source_id, 
					"atlas_coords": layer.get_cell_atlas_coords(cell),
					"alternative": layer.get_cell_alternative_tile(cell)
				})
		var center_cell = (start_cell + end_cell) / 2
		for item in layer_clipboard:
			item["offset"] = item["offset"] - (center_cell - start_cell)
		clipboard.append_array(layer_clipboard)


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
		"action": "copy" if copy_method == "copy" else "paste"
	})
	
	update_highlight()
	clipboard.clear()	


func cut():
	copy_selected()	
	
	var snapshot: Array = []
	
	for item in clipboard:
		var layer = item["layer"]
		var cell = item["cell"]
		snapshot.append({
			"layer": layer, 
			"cell": cell, 
			"source_id": layer.get_cell_source_id(cell), 
			"atlas_coords": layer.get_cell_atlas_coords(cell), 
			"alternative": layer.get_cell_alternative_tile(cell)
		})
		item["layer"].erase_cell(cell)
	
	undo_history.append({
		"snapshot": snapshot, 
		"clipboard": clipboard.duplicate(true), 
		"action": "cut"
	})
	
	update_highlight()


func undo():
	if undo_history.is_empty(): 
		print("Nothing to undo")
		return
	if Global.num_of_undos_available == 0: return
	
	var last_action = undo_history.pop_back()
	var changed_cells: Array[Vector2i] = []
	
	for tile in last_action["snapshot"]:
		var layer = tile["layer"]
		if tile["source_id"] == -1:
			layer.erase_cell(tile["cell"])
		else:
			layer.set_cell(tile["cell"], tile["source_id"], tile["atlas_coords"], tile["alternative"])
		changed_cells.append(tile["cell"])
	
	update_highlight()
	
	if last_action["action"] == "copy":
		clipboard.clear()
		Global.num_of_copies_available += 1
	if last_action["action"] == "cut":
		clipboard.clear()
		Global.num_of_cuts_available += 1
	if last_action["action"] == "paste":
		clipboard = last_action["clipboard"]
	Global.num_of_undos_available -= 1


func update_highlight() -> void:

	# Clear every highlight layer
	for highlighted_layer in highlighted_layers:
		highlighted_layer.clear()

	# Build a list of every editable tile
	var terrain_cells: Array[Vector2i] = []

	for layer in tile_layers:
		for cell in layer.get_used_cells():
			if !terrain_cells.has(cell):
				terrain_cells.append(cell)

	# Paint the terrain on every highlight layer
	for highlighted_layer in highlighted_layers:
		highlighted_layer.set_cells_terrain_connect(
			terrain_cells,
			TERRAIN_SET,
			TERRAIN
		)


func _draw() -> void:
	if selection_start_point != Vector2.ZERO:
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

	if !clipboard.is_empty() && !is_selecting && paste_preview_enabled:
		var preview_start = get_global_mouse_position() - copied_size / 2

		#draw_rect(
			#Rect2(preview_start, copied_size),
			#Color(0, 1, 0, 0.15),
			#true
		#)

		draw_rect(
			Rect2(preview_start, copied_size),
			Color.GREEN,
			false,
			1
		)
