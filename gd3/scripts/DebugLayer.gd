extends CanvasLayer

func _on_BtnPKWareTest_pressed():
	Game.do_PKWare_tests()
func _on_BtnLoadAutosave_pressed():
	Game.load_game("res://../tests/autosave.sav")

var prev_tile_test_value = -1
func _on_BtnTestTerrainImages_value_changed(value):
	for y in Map.PH_MAP_WIDTH:
		for x in Map.PH_MAP_WIDTH:
			if Map.grids.image.get_cell(x, y) == -1:
				Map.grids.image.set_cell(x, y, prev_tile_test_value)
			if Map.grids.image.get_cell(x, y) == value:
				Map.grids.image.set_cell(x, y, -1)
	prev_tile_test_value = value
