extends Panel

func _ready():
	GameEvents.connect("select_clay_pixels",self,"_on_emit_select_clay_pixels")
	
func _on_emit_select_clay_pixels():
	show()

func _on_HSlider_value_changed(value):
	
	var pixels = value * Globals.MAX_CLAY_PIXELS
	GameEvents.emit_clay_pixels_selected(pixels)


func _on_Select_pressed():
	GameEvents.emit_begin_throwing()
	hide()
	pass # Replace with function body.
