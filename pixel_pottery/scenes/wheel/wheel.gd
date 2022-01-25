extends Node2D


const GREEN = Color('3cd53e')
const RED = Color('933636')

const MIN_PEDAL_DEGREE = 0
const MAX_PEDAL_DEGREE = 45
const MAX_WHEEL_SPEED = 3
const WHEEL_WIDTH = 64

const CYCLES_BEFORE_FLIP = 5 #number of animation cycles before cells are fliped
const FRAMES_PER_CYCLE = 4

var wheel_on = false

var cycle = 0
var animation_state = 0
var speed = 0

var active_cells = {}

var session_log = []

func _ready():
	if Globals.data_collection:
		$symmetry_debug.text.show()
	toggle_on_off(false)
	GameEvents.connect("begin_throwing",self,"_on_begin_throwing")
	GameEvents.connect("new_session",self,"_on_new_session")
	GameEvents.connect("pixel_slider",self,"_on_pixel_slider")
	
func _on_new_session():
	toggle_on_off(false)
	session_log.clear()
	active_cells.clear()	
	
func _on_begin_throwing():
	toggle_on_off(true)


func toggle_on_off(state=!wheel_on):
	wheel_on = state
	power_light()
	if wheel_on:
		$AnimationPlayer.play("wheel_spin")
	else:
		$AnimationPlayer.stop()

func power_light():
	if wheel_on:
		$Textures/PowerLight.self_modulate = GREEN
		$Textures/ControlPanel.frame = 2
		
	else:
		$Textures/PowerLight.self_modulate = RED
		$Textures/ControlPanel.frame = 0
		


func _on_pixel_slider(value):
	
	var pixels = value * Globals.MAX_CLAY_PIXELS
	active_cells = $ClayCells.spawn_clay(pixels)
	var profile = $ClayProfiler.generate_profile(active_cells,animation_state)
	$ClayDrawing.draw_clay(profile)
#	GameEvents.emit_clay_pixels_selected(pixels)




#
#



func _on_pedal_handle_gui_input(event):
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			_rotate_pedal(event.relative)


func _rotate_pedal(motion:Vector2)->void:
	GameEvents.emit_tutorial_step(0)
	var new_pos = get_global_mouse_position()
	var prev_pos = new_pos - motion
	var offset = $PedalPivot.get_global_position()
	var angle = (prev_pos - offset).angle_to(new_pos-offset)
	$PedalPivot.rotation =  clamp(	$PedalPivot.rotation+angle, 
							deg2rad(Globals.MIN_PEDAL_DEGREE), 
							deg2rad(Globals.MAX_PEDAL_DEGREE))								
	speed = MAX_WHEEL_SPEED * ($PedalPivot.rotation_degrees / MAX_PEDAL_DEGREE)
	_update_wheel_speed()


func _update_wheel_speed() -> void:
	$AnimationPlayer.playback_speed = speed
	if speed == 0:
		$AnimationPlayer.stop()
	elif not $AnimationPlayer.is_playing():
		if wheel_on:
			$AnimationPlayer.play("wheel_spin")
		
		
func _on_wheel_rotation(frame):
	var cycle_frame = cycle * FRAMES_PER_CYCLE + (frame + 1)
	animation_state = float(cycle_frame) / float(CYCLES_BEFORE_FLIP * FRAMES_PER_CYCLE)
	var tool_cells =  $ToolBox.get_all_tool_cells($ClayDrawing.global_position)

	var collision_results = $ToolCollision.handle_tool_collisions(active_cells, tool_cells, speed)
	var saturated_cells = collision_results[0]
	var movement_occured = collision_results[1]
	
	var eroded_cells = $ClayErosion.handle_erosion(active_cells, WHEEL_WIDTH)

	if frame == FRAMES_PER_CYCLE-1:
		cycle += 1
	if cycle >= CYCLES_BEFORE_FLIP:
		active_cells = $ClayCells.flip_cells(active_cells)
		cycle = 0
		
	var profile = $ClayProfiler.generate_profile(active_cells,animation_state)
	if  tools_in_vessel(tool_cells, profile):
		$ClayDrawing.toggle_transparency(true)
	else:
		$ClayDrawing.toggle_transparency(false)
	$ClayParticles.draw_particles(saturated_cells, speed)
	$ClayParticles.draw_particles(eroded_cells, speed)
	$ClayDrawing.draw_clay(profile)
	if movement_occured:
		GameEvents.emit_tutorial_step(4)
		if Globals.data_collection:
			session_log.append(active_cells.keys())
			$symmetry_debug.text = str(Symmetry.score(active_cells.keys()))

func tools_in_vessel(tool_cells, profile):
	for t in tool_cells:
		if profile["full"].keys().has(t.y):
			if profile["full"][t.y][0] <= t.x and profile["full"][t.y][1] >= t.x:		
				return true
	return false




