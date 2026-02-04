extends TextureRect

func _on_BtnPlay_pressed():
	Game.go_to_menu("FamilySelection")
func _on_BtnWebsite_pressed():
	pass # Replace with function body.
func _on_BtnEditor_pressed():
	Game.popup_menu("MissionEditor")
func _on_BtnScores_pressed():
	Game.popup_menu("FamilyHighscores")
func _on_BtnQuit_pressed():
	Game.popup_menu("QuitGameConfirm")
