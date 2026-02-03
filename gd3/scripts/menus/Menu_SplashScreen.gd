extends TextureRect

func _on_Splash_focus_entered():
	Game.go_to_menu("Main")
	hide()
