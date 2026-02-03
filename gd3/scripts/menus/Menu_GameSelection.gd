extends TextureRect

func _on_BtnBegin_pressed():
	pass # Replace with function body.
func _on_BtnChooseMission_pressed():
	Game.open_popup("NoMissionWonYet")
func _on_BtnSaveGames_pressed():
	pass # Replace with function body.
func _on_BtnCustomMissions_pressed():
	pass # Replace with function body.
func _on_BtnBack_pressed():
	Game.go_to_menu("FamilySelection")

func _on_GameSelection_visibility_changed():
	if visible:
		$Panel/FamilyName.text = TranslationServer.translate("TEXT_293_5").replace("[player_name]", Family.current_family)

func _gui_input(event):
	if Game.right_click_pressed(self, event):
		_on_BtnBack_pressed()
