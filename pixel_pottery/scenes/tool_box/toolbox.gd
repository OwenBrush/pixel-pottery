extends Node2D

const MAX_TOOLS = 4
const TOOL_POSITIONS = [-9.5 , -2.5 , 4.5, 11.5]

var active = false



func _ready():
	GameEvents.connect("tool_released",self,"_on_tool_released")
	GameEvents.connect("session_end",self,'_on_session_end')
	put_away_tools()

func _on_session_end(_active_cells):
	put_away_tools()

func put_away_tools():
	for child in $Contents.get_children():
		hold_tool(child)


func _on_tool_released(t):
	if t.get_area2d() in $Area2D.get_overlapping_areas():
		hold_tool(t)


func activate_tool_box():
	active = true
	$ClickBox.mouse_filter = Control.MOUSE_FILTER_PASS


func hold_tool(t):
	if not t.is_in_group("tool"):
		return false
	if $Contents.get_child_count() >= TOOL_POSITIONS.size():
		return false
	if t.owner != self:
		t.get_parent().remove_child(t)
		t.set_owner(self)
		$Contents.add_child(t)
	t.active = false
	_position_tool(t)
#	t.position.x = TOOL_POSITIONS[0]
#	_determine_tool_position(t)
		
func _position_tool(t):
	var current_tools = _get_tool_positions()
	for i in TOOL_POSITIONS:
		if not current_tools.has(i):
			t.position.x = i
			t.position.y = 14 -  t.get_texture().get_size().x * .5
	t.rotation_degrees = 90 
	t.z_index = 0
	t.set_tool_area()

func _determine_tool_position(t):
	var free_positions = TOOL_POSITIONS
	for i in _get_tool_positions():
#		if free_positions.has(i):
		free_positions.erase(i)
	t.position.x = free_positions[0]
	
func _get_tool_positions():
	var positions = []
	for t in $Contents.get_children():
		positions.append(t.position.x)
	return positions


func get_all_tool_cells(drawing_position):
	var t_cells = {}
	for t in $Contents.get_children():
		var cells = t.get_tool_cells()
		for cell in cells:
			t_cells[ cell.round() - drawing_position] = t.strength
	return t_cells
	
	

func _on_ClickBox_clicked_by_player(event):
	if active:
		for t in $Contents.get_children():	
			t.trigger_click(event)

#func _input(event):
