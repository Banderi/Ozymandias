extends Control

func _on_BtnYes_pressed():
	Game.go_to_menu("ExploreHistory", true)
func _on_BtnNo_pressed():
	hide()

func _on_Panel_clicked_outside(_panel):
	hide()

func _gui_input(event):
	if Game.right_click_pressed(self, event):
		hide()
