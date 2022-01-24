extends Node2D




func _ready():
	GameEvents.connect("new_session",self,"_on_new_session")
	GameEvents.connect("begin_throwing",self,"_on_begin_throwing")
	GameEvents.connect("session_end",self,"_on_session_end")
	GameEvents.connect("final_score",self,"_on_final_score")
	GameEvents.emit_new_session()

func _on_new_session():
	$RatingPanel.hide()
	$FinishPanel.hide()
	$BeginPanel.show()
	call_deferred('_on_PixelSlider_value_changed', $BeginPanel/PixelSlider.value)

	
func _on_begin_throwing():
	$FinishPanel.show()
	$BeginPanel.hide()
	
func _on_session_end(_active_cells):
	$FinishPanel.hide()
	if Globals.data_collection:
		DataCollection.create_images_from_session_log($Wheel.session_log)
	
func _on_final_score(score):
	$RatingPanel/TextureProgress.value = score
	$RatingPanel.show()
	



	

	
func _on_Finish_pressed():
	GameEvents.emit_session_end($Wheel.active_cells)	


func _on_Begin_pressed():
	GameEvents.emit_begin_throwing()


func _on_PixelSlider_value_changed(value):
	GameEvents.emit_pixel_slider(value)


func _on_PlayAgain_pressed():
	GameEvents.emit_new_session()
