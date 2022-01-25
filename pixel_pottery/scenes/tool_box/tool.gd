extends Node2D

const ROTATION_STEP = 15

var active = false
var tool_cells = [] # array of cell vectors in relation to original position of tool
var drag = false
var click_offset = Vector2(0,0)
var rotation_offset = 0
var strength = 1


func _ready():
	set_tool_area()
	
func get_texture():
	return $Sprite.get_texture()
	
func get_area2d():
	return $CollisionArea	

func rotate_tool_with_mouse():
	GameEvents.emit_tutorial_step(2)
	rotation = rotation_offset + global_position.angle_to_point(get_global_mouse_position())
	set_tool_area()	
	

func get_tool_cells():
	var t_cells = []
	var off_set = global_position
	for vector in tool_cells:
		t_cells.append(vector+off_set.round())
	return  t_cells
	

func set_tool_area():	
	var xa = {}
	var poly_vectors = $CollisionArea/OuterCollision.polygon
	tool_cells.clear()
	for vector in poly_vectors:
		var rotated_vector = vector.rotated(deg2rad(rotation_degrees))
		var x = round(rotated_vector[0])
		if not xa.has(x):
			xa[x] = []
		xa[x].append(round(rotated_vector[1]))
	for x in xa.keys():
		for y in range(xa[x].min(),xa[x].max()):
			tool_cells.append(Vector2(x,y))


func _input(event):
	if active:
		if Input.is_action_just_pressed("ui_middle_mouse"):
			click_offset = global_position - get_global_mouse_position()
			
		if Input.is_action_just_pressed("ui_right_mouse"):
			rotation_offset = global_position.angle_to_point(get_global_mouse_position()) -rotation
		
		if Input.is_mouse_button_pressed(BUTTON_MIDDLE):
			if event is InputEventMouseMotion:
				GameEvents.emit_tutorial_step(3)
				global_position = get_global_mouse_position() +click_offset	

func _on_ReferenceRect_gui_input(event):
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(BUTTON_RIGHT):
			click_offset = get_global_mouse_position()
			rotate_tool_with_mouse()
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			global_position = get_global_mouse_position()
			GameEvents.emit_tutorial_step(1)
			active = true

	if Input.is_action_just_released("ui_left_mouse"):
		GameEvents.emit_tool_relealsed(self)

