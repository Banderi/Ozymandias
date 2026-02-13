extends CanvasLayer

func _on_BtnPKWareTest_pressed():
	Game.do_PKWare_tests()
func _on_BtnLoadAutosave_pressed():
	Game.load_game("res://../tests/autosave.sav")

var prev_tile_test_value = 2
func _on_BtnTestTerrainImages_value_changed(value):
	var found = 0
	for y in Map.PH_MAP_WIDTH:
		for x in Map.PH_MAP_WIDTH:
			if Map.grids.images.get_cell(x, y) == 2:
				Map.grids.images.set_cell(x, y, prev_tile_test_value)
			if Map.grids.images.get_cell(x, y) == value:
				Map.grids.images.set_cell(x, y, 2)
				found += 1
	print("found: ", found, " cells")
				
	prev_tile_test_value = value
#	$TextureRect.texture = Assets.get_sg_texture("Pharaoh_General", value)

func _ready():
	yield(Assets, "ready")
#	$TextureRect.texture = Assets.get_sg_texture("Pharaoh_General.sg3", 260)
	$DEBUG_LABEL3.bbcode_text = ""

func _input(event):
	if Game.STATE == Game.States.Ingame:
		if event is InputEventMouseMotion:
			var mouse_pos = Game.INGAME_ROOT.get_local_mouse_position()
			var tile_coords = Map.TILEMAP_FLAT.world_to_map(mouse_pos)
			var world_coords = Map.TILEMAP_FLAT.map_to_world(tile_coords)
			Game.INGAME_ROOT.get_node("CURSOR").position = world_coords
			
			var tile_text = ""
			tile_text += "tile: %s\n" % [tile_coords]
#			tile_text += "[color=#ffcc00]image:[/color]      %d\n" % [Map.TILEMAP_FLAT.get_cellv(tile_coords)]
			tile_text += "[color=#ffcc00]image:[/color]      %d\n" % [Map.grids.images[tile_coords.y][tile_coords.x]]
			tile_text += "[color=#ffcc00]edge:[/color]       %d\n" % [Map.grids.edge[tile_coords.y][tile_coords.x]]
			tile_text += "[color=#ffcc00]buildings:[/color]  %d\n" % [Map.grids.buildings[tile_coords.y][tile_coords.x]]
			
			var tile_terrain = Map.grids.terrain[tile_coords.y][tile_coords.x]
			tile_text += "[color=#ffcc00]terrain:[/color]    %d\n" % [tile_terrain]
			for flag in Map.TerrainFlags:
				if tile_terrain & Map.TerrainFlags[flag]:
					tile_text += "  [color=#888888]%s[/color]\n" % [flag]
			if $DEBUG_LABEL3.bbcode_text != tile_text:
				$DEBUG_LABEL3.bbcode_text = tile_text
			$DEBUG_LABEL3.rect_position = $DEBUG_LABEL3.get_global_mouse_position() - Vector2(100, 200)
