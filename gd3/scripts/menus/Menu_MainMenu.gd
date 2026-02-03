extends TextureRect

func _on_BtnPlay_pressed():
	Game.go_to_menu("FamilySelection")
func _on_BtnWebsite_pressed():
	pass # Replace with function body.
func _on_BtnEditor_pressed():
	pass # Replace with function body.
func _on_BtnScores_pressed():
	pass # Replace with function body.
func _on_BtnQuit_pressed():
	Game.open_popup("QuitGameConfirm")
