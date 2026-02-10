extends CanvasLayer

func _on_BtnPKWareTest_pressed():
	Game.do_PKWare_tests()
func _on_BtnLoadAutosave_pressed():
	Game.load_game("res://../tests/autosave.sav")
