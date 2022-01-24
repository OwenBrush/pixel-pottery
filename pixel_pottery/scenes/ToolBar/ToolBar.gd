extends GUIElement


func _on_Purchase_pressed():
	emit_signal("open_element" , Database.GUI.PURCHASE)
