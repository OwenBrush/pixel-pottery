extends Node2D


#directions
const LEFT = Vector2(-1,0)
const UP = Vector2(0,-1)
const RIGHT = Vector2(+1,0)
const DOWN = Vector2(0,+1)

var connected_cells = []
var active_cells = {}
var eroded_cells = {}
var base_cells = {}
#var cells_to_remove = {}

func handle_erosion(cells, wheel_width):
	var left_edge = round( - wheel_width*.5)
	var right_edge = round(wheel_width * .5)
	active_cells = cells
	base_cells.clear()
	connected_cells.clear()
	var cells_to_remove = {}
	_cull_disconected_cells(left_edge, right_edge)
	if base_cells.size() > 0:
		#Sort cells into "bases" so that only the biggest base is saved
		var main_base = base_cells.keys()[0]
		for base in base_cells.keys():
			if base_cells[base].size() > base_cells[main_base].size():
				main_base = base
		
#		print(str(base_cells.size() )+ " " +str(biggest) + " " + str(base_cells[biggest].size()) )
		
		for cell in active_cells:
			if not base_cells[main_base].has(cell):
				eroded_cells[cell] = active_cells[cell]
				cells_to_remove[cell] = active_cells[cell]
			elif cell[1] == 0:
				if cell[0] < left_edge or cell[0] > right_edge:
					eroded_cells[cell] = active_cells[cell]
					cells_to_remove[cell] = active_cells[cell]
		if eroded_cells.size() > 0:
			for cell in eroded_cells:
				active_cells.erase(cell)
		eroded_cells.clear()
	elif base_cells.size() == 0:
		cells_to_remove = active_cells
		active_cells.clear()
#	GameEvents.emit_draw_clay_particles(cells_to_remove, Globals.wheel_speed)	
	return cells_to_remove

func _cull_disconected_cells(left_edge, right_edge):
	for x in range (left_edge , right_edge):
		if active_cells.has(Vector2(x,0)):
			base_cells[Vector2(x,0)] = []
#			base_cells[Vector2(x,y)].append(Vector2(x,y))
	for base in base_cells.keys():
		if not connected_cells.has(base):
			_scan_for_connections(base , base)		
#			
func _scan_for_connections(cell ,  base):
	var x = cell[0]
	var y = cell[1]
	while true:
		var x_origin = x
		var y_origin = y
		while active_cells.has(Vector2(x,y)+UP) and not connected_cells.has(Vector2(x,y)+UP):
			y += UP[1]
		while active_cells.has(Vector2(x,y)+LEFT) and not connected_cells.has(Vector2(x,y)+LEFT) :
			x += LEFT[0]
		if x == x_origin and y == y_origin:
			break
	_fill_block(Vector2(x,y) , base)		

func _fill_block(cell , base):
	var x = cell[0]
	var y = cell[1]
	var last_row_length = 0
	var first_iteration = true
	#
	while last_row_length > 0 or first_iteration:
		first_iteration = false
		var row_length = 0
		var scanning_x = x
		#
		if last_row_length > 0 and ( connected_cells.has(Vector2(x,y)) or not active_cells.has(Vector2(x,y)) ):
			row_length -= 1	
			last_row_length -= 1		
			while row_length > 0 and ( connected_cells.has(Vector2(x+1,y)) or not active_cells.has(Vector2(x+1,y)) ):
				x += 1
				row_length -= 1
				last_row_length -= 1	
			scanning_x = x	
		#
		else:
			while active_cells.has(Vector2(x-1,y)) and not connected_cells.has(Vector2(x-1,y)):
				connected_cells.append(Vector2(x-1,y))
				base_cells[base].append(Vector2(x-1,y))
				row_length += 1
				last_row_length += 1
				x -= 1
				if active_cells.has(Vector2(x,y-1)) and not connected_cells.has(Vector2(x,y-1)):
					_scan_for_connections(Vector2(x,y-1) , base)
		#
		while active_cells.has(Vector2(scanning_x,y)) and not connected_cells.has(Vector2(scanning_x,y)):
			connected_cells.append(Vector2(scanning_x,y))
			base_cells[base].append(Vector2(scanning_x,y))
			row_length += 1
			scanning_x += 1
		#
		if row_length < last_row_length:
			var end = x+last_row_length
			while scanning_x <= end:
				if active_cells.has(Vector2(scanning_x,y)) and not connected_cells.has(Vector2(scanning_x,y)):
					_fill_block(Vector2(scanning_x,y) , base)
				scanning_x += 1
		#
		elif row_length > last_row_length:
			var up_end = x + last_row_length
			while up_end <= scanning_x:
				if active_cells.has(Vector2(up_end,y-1)) and not connected_cells.has(Vector2(up_end,y-1)):
					_fill_block(Vector2(up_end,y-1) , base)
				up_end += 1
		last_row_length  = row_length
		y+=1			
	pass	##

func within_erosion_threshold(cell):
	var body = active_cells[cell]["body"] - active_cells[cell]["body"]*active_cells[cell]["saturation"]
	if active_cells.has(cell+LEFT):
		body += active_cells[cell+LEFT]["body"] - active_cells[cell+LEFT]["body"]*active_cells[cell+LEFT]["saturation"]
	if active_cells.has(cell+RIGHT):
		body += active_cells[cell+RIGHT]["body"] - active_cells[cell+RIGHT]["body"]*active_cells[cell+RIGHT]["saturation"]
	if active_cells.has(cell+UP):
		body += active_cells[cell+UP]["body"] - active_cells[cell+UP]["body"]*active_cells[cell+UP]["saturation"]
	if active_cells.has(cell+DOWN):
		body += active_cells[cell+DOWN]["body"] - active_cells[cell+DOWN]["body"]*active_cells[cell+DOWN]["saturation"]
	if body > active_cells["body"]*get_owner().EROSION_THRESHOLD:
		return true
	else:
		return false
