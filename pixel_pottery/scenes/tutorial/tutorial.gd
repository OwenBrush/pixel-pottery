extends Control

export(Array, NodePath) var tutorial_steps

const PHADE_SPEED = 0.5

var step = 0
var game_started = false



# Called when the node enters the scene tree for the first time.
func _ready():
	GameEvents.connect("tutorial_step",self,"_on_tutorial_step")
	GameEvents.connect("begin_throwing",self,"_on_begin_throwing")
	GameEvents.connect("session_end",self,"_on_session_end")
	pass # Replace with function body.

func _on_session_end(_active_cells):
	_phade_out_element(self)

func _on_begin_throwing():
	game_started = true
	var node = get_node(tutorial_steps[0])
	_phade_in_element(node)

func _on_tutorial_step(step_signal):
	if game_started:
		if step_signal == step:
			step+=1
			var old_node = get_node(tutorial_steps[step_signal])
			_phade_out_element(old_node)
		
			if step_signal+1 >= len(tutorial_steps):
				_phade_out_element(self)
			else:
			
				var new_node = get_node(tutorial_steps[step])
				_phade_in_element(new_node)

		
func _phade_in_element(node):
	node.show()
	var tween := Tween.new()
	node.add_child(tween)
	tween.interpolate_property(node, "modulate", Color(1,1,1,0), Color(1,1,1,1), PHADE_SPEED)
	tween.set_active(true)
		
func _phade_out_element(node):
	var tween := Tween.new()
	node.add_child(tween)
	tween.interpolate_property(node, "modulate", Color(1,1,1,1), Color(1,1,1,0), PHADE_SPEED)
	tween.interpolate_callback(node, PHADE_SPEED, 'queue_free')
	tween.set_active(true)


