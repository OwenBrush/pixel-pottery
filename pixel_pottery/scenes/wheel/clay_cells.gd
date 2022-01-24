extends Node2D

func spawn_clay(pixels: int) -> Dictionary:
	var cells = {}
	var splat_factor = clamp(1 - (Globals.clay_body + Globals.clay_saturation) , 0 , 1 )
	var base_width = sqrt(pixels) + sqrt(pixels) * splat_factor
	var right = round(base_width*.5)
	var left = -round(base_width*.5)
	
	var y = 0
	while pixels > 0:
		pixels = _distribute_cells(cells, left, right, y, pixels)
		y -= 1
		
		var columns = right + abs(left)
		var min_rows = pixels / columns
		var max_reduction = (columns - min_rows) * .5	
		if max_reduction > 0:
			if left < -1:
				left += round(rand_range(0,max_reduction*.5))
			if right > 1:
				right -= round(rand_range(0,max_reduction*.5))
				
	return cells

func _distribute_cells(cells, left, right, y, pixels):
	for x in range(left, right):
		var new_cell = Vector2(x,y).round()
		if pixels > 0 and not cells.has(new_cell):
			pixels -= 1
			cells[new_cell] = {}
			cells[new_cell]["body"] = Globals.clay_body
			cells[new_cell]["saturation"] = 0
			cells[new_cell]["plasticity"] = Globals.clay_plasticity	
#			active_cells[new_cell]["color"] = Globals.clay_color		
	return pixels

func flip_cells(cells):
	var new_active_cells = {}
	for cell in cells:
		var mirror_cell = Vector2(0,cell[1])
		if cell[0] > 0:
			mirror_cell[0] = 0 - (cell[0] - (0-1))
		else:
			mirror_cell[0] = ((0-1) - cell[0]) + 0
		new_active_cells[mirror_cell] = cells[cell]
	return new_active_cells

#
#func _on_wheel_rotation(frame):
#	var cycle_frame = cycle  * FRAMES_PER_CYCLE + (frame + 1)
#	animation_state = float(cycle_frame) /  float(CYCLES_BEFORE_FLIP * FRAMES_PER_CYCLE)
#	var tool_cells =  get_all_tool_cells()
#
#	tool_collisions(tool_cells, animation_state)
#
#	if frame == FRAMES_PER_CYCLE-1:
#		cycle += 1
#	if cycle >= CYCLES_BEFORE_FLIP:
#		active_cells = _flip_cells(active_cells)
#		cycle = 0
#	GameEvents.emit_draw_clay(active_cells, animation_state)
#
#
#
#
#
#func get_all_tool_cells():
#	var t_cells = {}
#	for t in get_tree().get_nodes_in_group("tool"):
#		var cells = t.get_tool_cells()
#		for cell in cells:
#			t_cells[cell.round() - Globals.drawing_position] = t.strength
#	return t_cells
#
#func _flip_cells(cells):
#	var new_active_cells = {}
#	for cell in cells:
#		var mirror_cell = Vector2(0,cell[1])
#		if cell[0] > 0:
#			mirror_cell[0] = 0 - (cell[0] - (0-1))
#		else:
#			mirror_cell[0] = ((0-1) - cell[0]) + 0
#		new_active_cells[mirror_cell] = cells[cell]
##	active_cells.clear()
##	active_cells = new_active_cells
#	return new_active_cells
#
#func tool_collisions(tool_cells, animation_state):
#	active_cells = CellCollision.handle_tool_collisions(active_cells , tool_cells , Globals.wheel_speed)
#	active_cells = CellErosion.handle_erosion(active_cells , Globals.WHEEL_WIDTH)
#	var profile = ClayProfiler.generate_profile(active_cells, animation_state)
#	if  tools_in_vessel(tool_cells, profile):
#		GameEvents.emit_toggle_transparency(true)
#	else:
#		GameEvents.emit_toggle_transparency(false)
#
#
#func tools_in_vessel(tool_cells, profile):
#	for t in tool_cells:
#		if profile["full"].keys().has(t.y):
#			if profile["full"][t.y][0] <= t.x and profile["full"][t.y][1] >= t.x:		
#				return true
#	return false

	
