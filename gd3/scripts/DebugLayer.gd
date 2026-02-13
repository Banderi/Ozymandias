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
			if Map.TILEMAP_FLAT.get_cell(x, y) == 2:
				Map.TILEMAP_FLAT.set_cell(x, y, prev_tile_test_value)
			if Map.TILEMAP_FLAT.get_cell(x, y) == value:
				Map.TILEMAP_FLAT.set_cell(x, y, 2)
				found += 1
	print("found: ", found, " cells")
				
	prev_tile_test_value = value
#	$TextureRect.texture = Assets.get_sg_texture("Pharaoh_Terrain.sg3", value)
	$TextureRect.texture = Assets.get_gameset_sg_texture(value)

func _ready():
	yield(Assets, "ready")
#	$TextureRect.texture = Assets.get_sg_texture("Pharaoh_General.sg3", 260)
	$DEBUG_LABEL3.bbcode_text = ""

onready var CURSOR = Game.INGAME_ROOT.get_node("CURSOR")
func _input(event):
	if Game.STATE == Game.States.Ingame:
		if event is InputEventMouseMotion:
			var mouse_pos = Game.INGAME_ROOT.get_local_mouse_position()
			var tile_coords = Map.TILEMAP_FLAT.world_to_map(mouse_pos)
			
			var tile_text = ""
			if Rect2(0, 0, Map.PH_MAP_WIDTH, Map.PH_MAP_WIDTH).has_point(tile_coords):
				CURSOR.position = Map.TILEMAP_FLAT.map_to_world(tile_coords)
				CURSOR.show()
			
				tile_text += "tile: %s\n" % [tile_coords]
#				tile_text += "[color=#ffcc00]image:[/color]      %d\n" % [Map.TILEMAP_FLAT.get_cellv(tile_coords)]
				tile_text += "[color=#ffcc00]image:[/color]      %d\n" % [Map.grids.images[tile_coords.y][tile_coords.x]]
				tile_text += "[color=#ffcc00]edge:[/color]       %d\n" % [Map.grids.edge[tile_coords.y][tile_coords.x]]
				tile_text += "[color=#ffcc00]buildings:[/color]  %d\n" % [Map.grids.buildings[tile_coords.y][tile_coords.x]]
				
				# terrain
				var _terrain = Map.grids.terrain[tile_coords.y][tile_coords.x]
				tile_text += "[color=#ffcc00]terrain:[/color]    %d\n" % [_terrain]
				for flag in Map.TerrainFlags:
					if _terrain & Map.TerrainFlags[flag]:
						tile_text += "  [color=#888888]%s[/color]\n" % [flag]
						
				# edge
				var _edge = Map.grids.edge[tile_coords.y][tile_coords.x]
				tile_text += "[color=#ffcc00]edge:[/color]       %d\n" % [_edge]
				if _terrain & Map.TerrainFlags.BUILDING == Map.TerrainFlags.BUILDING:
					for i in 6:
						var flag = str("ROW_", i)
						if _edge & Map.EdgeFlags.MASK_ROW == Map.EdgeFlags[flag]:
							tile_text += "  [color=#888888]%s[/color]\n" % [flag]
					for i in 6:
						var flag = str("COLUMN_", i)
						if _edge & Map.EdgeFlags.MASK_COLUMN == Map.EdgeFlags[flag]:
							tile_text += "  [color=#888888]%s[/color]\n" % [flag]
				if _edge & Map.EdgeFlags.DRAW_TILE == Map.EdgeFlags.DRAW_TILE:
					tile_text += "  [color=#888888]DRAW_TILE[/color]\n"
				if _edge & Map.EdgeFlags.NATIVE_LAND == Map.EdgeFlags.NATIVE_LAND:
					tile_text += "  [color=#888888]NATIVE_LAND[/color]\n"
						
				# bitfields
				var _bitfields = Map.grids.bitfields[tile_coords.y][tile_coords.x]
				tile_text += "[color=#ffcc00]bitfields:[/color]  %d\n" % [_bitfields]
				if _terrain & Map.TerrainFlags.BUILDING == Map.TerrainFlags.BUILDING:
					for i in 8:
						var flag = str("SIZE_", i + 1)
						if _bitfields & Map.BitFlags.MASK_SIZE == Map.BitFlags[flag]:
							tile_text += "  [color=#888888]%s[/color]\n" % [flag]
				for flag in Map.BitFlags:
					if _bitfields & Map.BitFlags[flag] in [16, 32, 64, 128]:
						tile_text += "  [color=#888888]%s[/color]\n" % [flag]
					
			else:
				CURSOR.hide()
			
			if $DEBUG_LABEL3.bbcode_text != tile_text:
				$DEBUG_LABEL3.bbcode_text = tile_text
			$DEBUG_LABEL3.rect_position = $DEBUG_LABEL3.get_global_mouse_position() - Vector2(100, 200)


func _on_BtnRedrawMap_pressed():
	Map.redraw()
