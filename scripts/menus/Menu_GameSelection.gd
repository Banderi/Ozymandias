extends TextureRect

func _on_BtnResume_pressed():
	Game.load_game(Family.get_most_recent_family_save())
func _on_BtnBegin_pressed():
	Game.go_to_menu("ExploreHistory", false) # "Begin family history" simply opens the campaign explore, but with missions locked
func _on_BtnChooseMission_pressed():
	if !Family.has_beaten_any_mission():
		Game.popup_menu("NoMissionWonYet")
	else:
		Game.go_to_menu("ExploreHistory", true)
func _on_BtnSaveGames_pressed():
	Game.popup_menu("SavegameSelection", false)
func _on_BtnCustomMissions_pressed():
	Game.go_to_menu("CustomMissions", false)
func _on_BtnBack_pressed():
	Family.current_family = null
	Game.go_to_menu("FamilySelection", Family.current_family)

func _on_menu_open(data):
	Family.current_family = data
	$Panel/FamilyName.text = TranslationServer.translate("TEXT_293_5").replace("[player_name]", Family.current_family)
	if !Family.has_beaten_any_mission():
		$Panel/VBoxContainer/BtnBegin.show()
		$Panel/VBoxContainer/BtnResume.hide()
		$Panel/VBoxContainer/BtnSaveGames.disabled = true
	else:
		$Panel/VBoxContainer/BtnBegin.hide()
		$Panel/VBoxContainer/BtnResume.show()
		$Panel/VBoxContainer/BtnSaveGames.disabled = false

func _gui_input(event):
	if Game.right_click_pressed(self, event):
		_on_BtnBack_pressed()

