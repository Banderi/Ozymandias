extends TextureRect

func _on_Splash_focus_entered():
	Game.open_menu("Main")
	hide()
