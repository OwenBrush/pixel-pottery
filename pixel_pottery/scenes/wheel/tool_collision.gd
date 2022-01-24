#Moves cells to new locations based on cells occupied by tools
#-gets tool_cells
#-gives new active_cells

extends Node2D
###Arrays for tracking cells###
var active_cells = {}
var tool_cells = {}
var moving_cells = {}
var new_cells = {}
#var cells_to_remove = {}
#var wall_profile = {}

###Constants####
const LEFT = Vector2(-1,0)
const UP = Vector2(0,-1)
const RIGHT = Vector2(+1,0)
const DOWN = Vector2(0,+1)
const MOVEMENT_MAX = 32
const MOVEMENT_MIN = 1
const MAX_SPEED  = 2
const SATURATION_MOD = 0.1 #How much saturation is given to a cell when it is moved
###Variables for matching cell locations to display###


const EIGHT_DIRECTIONS = [DOWN , DOWN+LEFT , LEFT , LEFT+UP , UP , UP+RIGHT , RIGHT , RIGHT+DOWN]
const REQ_NEIGHBOURS = 3
###Detect which active cells are overlaping with tool cells and add them to list of cells to move###

##FOR TESTING
var slumped = []
var draw_slumped = []
var draw_not_slump = []
var draw_neighbours = []
var draw_missing_neighbours = []

#func _draw():
#	for cell in draw_not_slump:
#		draw_line(cell,cell+Vector2(1,0),Color(0,1,0,1),1.00001,false)
#	for cell in draw_neighbours:
#		draw_line(cell,cell+Vector2(1,0),Color(0,0,1,1),1.00001,false)
#	for cell in draw_missing_neighbours:
#		draw_line(cell,cell+Vector2(1,0),Color(0,1,1,1),1.00001,false)
#	for cell in draw_slumped:
#		draw_line(cell,cell+Vector2(1,0),Color(1,0,0,1),1.00001,false)
			
func handle_tool_collisions(a_cells,t_cells, speed):
#	slumped.clear()
#	draw_slumped.clear()
#	draw_not_slump.clear()
#	draw_neighbours.clear()
#	draw_missing_neighbours.clear()
	
	active_cells = a_cells
	tool_cells = t_cells
	moving_cells.clear()
#	new_cells.clear()
	
	var cells_to_remove = {}
	
	for cell in tool_cells.keys():

		if active_cells.has(cell):
			#Make sure cell is on the edge of the form, and not in the middle.
			if 	( not active_cells.has(cell+UP) or not active_cells.has(cell+RIGHT) or not active_cells.has(cell+LEFT) 
				or
				( not active_cells.has(cell+DOWN) and not (cell+DOWN)[1] > 0 ) ):
					#Mark cells for removal and erase from active cells if they have more saturation than body
					if active_cells[cell]["saturation"] >= active_cells[cell]["body"]:
						cells_to_remove[cell] = active_cells[cell]
						active_cells.erase(cell)
					#Else, mark cell for movement and add the tool strength to it's entry.
					else:
						moving_cells[cell] = active_cells[cell]
						moving_cells[cell]["tool"] = tool_cells[cell]
	#Execute movement
	for cell in moving_cells:
		_handle_cell_movement(cell, speed)
#	GameEvents.emit_draw_clay_particles(cells_to_remove,speed)
	return [cells_to_remove, moving_cells.size() > 0]


#Assign new location to cell untill it is placed in an open space	
func _handle_cell_movement(cell, speed):
	var new_cell = cell
	var iteration = 0
	var tool_strength = moving_cells[cell]["tool"]
	#Continue moving cell untill it has been moved to an empty new location
	while active_cells.has(new_cell) or moving_cells.has(new_cell) or new_cell == cell:
		#Assign cell an order of movement to execute first to last
		var directions = _direction_of_movement(new_cell)
		new_cell = _move_cell(new_cell , speed,directions , tool_strength)
		iteration +=1
		if iteration >1000:
			print("movement timed out")
			break
	#Move cell to new location in dictionary,  apply saturation, and erase old entry
	active_cells[new_cell] = active_cells[cell]
	active_cells[new_cell]["saturation"] += SATURATION_MOD*moving_cells[cell]["tool"]
	active_cells.erase(cell)
	#Check for a sufficient amount of neighbours to hold cell - move it downwards if not
###SLUMPING###
	if not _sufficient_neighbours(new_cell, active_cells[new_cell]["body"], active_cells[new_cell]["saturation"]):
		_handle_slumping(new_cell)
	
func _handle_slumping(cell):
	var new_cell = cell
	var body = active_cells[cell]["body"]
	var saturation = active_cells[cell]["saturation"]
	var sufficient_neighbours = false
	var iteration = 0
	var dir = RIGHT
	if cell[0] < 0:
		dir = LEFT
	while not sufficient_neighbours:
		var slumped_cell = _slump_cell(new_cell, dir)
		if slumped_cell:
			cell = new_cell
			new_cell = slumped_cell
			active_cells[new_cell] = active_cells[cell]
			active_cells.erase(cell)
		sufficient_neighbours = _sufficient_neighbours(new_cell , body , saturation)
		iteration += 1
		if iteration > 1000:
			draw_slumped = slumped
			draw_not_slump = active_cells.keys()
			print("Slumping timed out")
			print(sufficient_neighbours)
			update()
			break
#			break

	


func _direction_of_movement(cell):
	var tool_to_left = _tool_present(cell,LEFT)
	var tool_to_right = _tool_present(cell,RIGHT)
	#If no tool cell is on this row, move outwards and upwards first
	if not tool_to_left and not tool_to_right:
		if  cell[0] < 0:
			return [LEFT,UP,DOWN]
		else:
			return [RIGHT,UP,DOWN]
	#if tool cells are to left and right, move upwards or downwards first	
	elif tool_to_left and tool_to_right:
		if _tool_present(cell,UP):
			if cell[1] < 0:
				if  cell[0] < 0:			
					return [DOWN,LEFT, RIGHT]
				else:
					return [DOWN, RIGHT, LEFT]
									
			else:
				if  cell[0] < 0:
					return [LEFT,UP,RIGHT]
				else:
					return [RIGHT,UP,RIGHT]
		else:
			if  cell[0] < 0:	
				return [UP,LEFT,RIGHT]
			else:
				return [UP,RIGHT,LEFT]
	#if tool cells are to left and not right, move right
	elif tool_to_left and not tool_to_right:
		return [RIGHT,UP,DOWN]
	#if tool cells are to right and not left, move left
	elif tool_to_right and not tool_to_left:
		return [LEFT,UP,DOWN]


func _sufficient_neighbours(cell , body , saturation):
	var req = REQ_NEIGHBOURS
	#Ajust requirements so high body clay needs fewer neighbours
	var req_modifier = round( REQ_NEIGHBOURS * ( body - saturation ) )
	req = clamp(req - req_modifier, 1, REQ_NEIGHBOURS)
	var count = 0
	for dir in EIGHT_DIRECTIONS:
		if active_cells.has(cell+dir) or (cell+dir)[1]>0:
			count += 1
			draw_neighbours.append(cell+dir)
			if count >= req:
				return true
		else:
			draw_missing_neighbours.append(cell+dir)
				
	return false
		

func _slump_cell(cell , dir):
	var directions = []
	match dir:
		LEFT:
			directions = [DOWN, DOWN+LEFT , LEFT]
		RIGHT:
			directions = [DOWN, DOWN+RIGHT , RIGHT]
			
	for dir in directions:
		if not active_cells.has(cell+dir):
			if not moving_cells.has(cell+dir):
				if not cell[1] > 0:
					slumped.append(cell+dir)
					return cell+dir
	return false

func _tool_present(cell,dir):
	while active_cells.has(cell) or moving_cells.has(cell):
		if not active_cells.has(cell+dir) and not moving_cells.has(cell+dir):
			if tool_cells.has(cell+dir):
				return true
			else:
				return false
		cell+=dir













func _move_cell(cell,speed, direction, tool_strength):
	var plasticity = 0
	var saturation = 0
	if active_cells.has(cell):
		plasticity = active_cells[cell]["plasticity"]
		saturation = active_cells[cell]["saturation"]
	elif moving_cells.has(cell):
		plasticity = moving_cells[cell]["plasticity"]
		saturation = moving_cells[cell]["saturation"]
	#Cell will move further the more plastic and saturated it is	
	var movement = plasticity + saturation
	# high speed  and high tool strength will increase movement, and vice versa for low
	movement *= speed - (1 - tool_strength)
	# determine what degree of the maximum movement this cell is allowed
	movement = clamp(MOVEMENT_MAX*movement, MOVEMENT_MIN , MOVEMENT_MAX )

#	var new_cell = cell
	for i in range(0, movement, +1):
		if _open_cell(cell + direction[0]):
			return cell + direction[0]
		else:
			for j in range(1 , i, +1):
				if _open_cell(cell + j*direction[1]):
					return cell + j*direction[1]			
				if _open_cell(cell + j*direction[2]):
					return cell + j*direction[2]	
		cell+=direction[0]
	return cell.round() 
			

			
func _open_cell(cell):
	if not active_cells.has(cell):
		if not moving_cells.has(cell):
			if not tool_cells.has(cell):
				if not cell[1] > 0:
					return true
	return false


func flip_cells(cells):
	var new_active_cells = {}
	for cell in cells:
		var mirror_cell = Vector2(0,cell[1])
		if cell[0] > 0:
			mirror_cell[0] = 0 - (cell[0] - (0-1))
		else:
			mirror_cell[0] = ((0-1) - cell[0]) + 0
		new_active_cells[mirror_cell] = cells[cell]
#	active_cells.clear()
#	active_cells = new_active_cells
	return new_active_cells
	

