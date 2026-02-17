extends TextureRect

func _on_BtnChooseEgyptian_pressed():
	Game.popup_menu("FamilyEgyptianName")
func _on_BtnContinue_pressed():
	Game.go_to_menu("FamilySelection", $Panel/LineEditFamilyName/LineEdit.text)

func _gui_input(event):
	if Game.right_click_pressed(self, event):
		Game.go_to_menu("FamilySelection")

func _on_menu_open(data):
	if data != null:
		$Panel/LineEditFamilyName/LineEdit.text = data
	$Panel/LineEditFamilyName/LineEdit.grab_focus()
	$Panel/LineEditFamilyName/LineEdit.caret_position = $Panel/LineEditFamilyName/LineEdit.text.length()
