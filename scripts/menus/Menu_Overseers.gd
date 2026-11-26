extends ColorRect

#func _on_menu_open(data):
#	pass

func _gui_input(event):
	if Game.right_click_pressed(self, event):
		Overseers.close()
func _input(event):
	if !visible:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		Overseers.close()
