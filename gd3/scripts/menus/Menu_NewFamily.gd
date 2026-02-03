extends TextureRect

func _on_BtnChooseEgyptian_pressed():
	Game.open_popup("FamilyEgyptianName")
func _on_BtnContinue_pressed():
	Game.go_to_menu("FamilySelection")

func _gui_input(event):
	if Game.right_click_pressed(self, event):
		Game.go_to_menu("FamilySelection")

func _process(delta):
	if Family.newfamily_textbox_temp != null:
		$Panel/LineEditFamilyName/LineEdit.text = Family.newfamily_textbox_temp
		Family.newfamily_textbox_temp = null
