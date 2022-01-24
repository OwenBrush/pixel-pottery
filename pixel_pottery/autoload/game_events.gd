extends Node

signal pixel_slider(value)
signal begin_throwing()
signal tool_released(t)
signal new_session()
signal session_end(cells)
signal final_score(score)
# For tutorial:
signal tutorial_step(step)



func emit_pixel_slider(value):
	emit_signal("pixel_slider", value)

func emit_session_end(cells):
	emit_signal("session_end", cells)
	
func emit_begin_throwing():
	emit_signal("begin_throwing")

func emit_tool_relealsed(t):
	emit_signal("tool_released",t)

func emit_new_session():
	emit_signal('new_session')
	
func emit_final_score(score):
	emit_signal("final_score", score)

func emit_tutorial_step(step):
	emit_signal("tutorial_step",step)
