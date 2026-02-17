extends Button

func _gui_input(event):
	get_child(0)._gui_input(event)
func _on_Button4Container_mouse_entered():
	get_child(0)._on_Button_mouse_entered(true)
func _on_ButtonContainer_mouse_exited():
	get_child(0)._on_Button_mouse_exited(true)
