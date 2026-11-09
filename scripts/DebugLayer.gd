extends CanvasLayer
	
func _on_SpinBoxSpeed_value_changed(value):
	Game.speed = value
	$DEBUG_LABEL/HSliderSpeed.value = value
func _on_HSliderSpeed_value_changed(value):
	Game.speed = value
	$DEBUG_LABEL/SpinBoxSpeed.value = value

func _on_BtnPKWareTest_pressed():
	Game.do_PKWare_tests()
func _on_BtnTest2_pressed():
	var _t = Stopwatch.start()
	print(_t)
#	var lemhlkr = 3674
	for x in 228:
		for y in 228:
			Map.TILEMAP_FLAT.set_cell(x, y, 14453 + rand_range(1,400))
	for i in range(0, 51000):

#		var a = Figures.figures[0].data.anim_frame
#		var a = Figures.figures[0].FIGURE_IDX
#		var a = Figures.figures[0].get2("anim_frame")
#		var a = Figures.figures[0].get2("destination_tile_grid")
#		var a = Figures.figures[0].animation_get_sprite_idx()
##		var a = Figures.figures[0].get2("destination_tile_grid")
#		if a == null:
#			return
##		var a = 100
#		var b = lemhlkr
#		if a[1] < b:
#			pass
#		Map.TILEMAP_FLAT.set_cell(114, 114, 14453 + rand_range(1,400))
#		Map.TILEMAP_FLAT.set_cell(114, 114, -1)
		pass
	yield(get_tree(), "idle_frame")
	Stopwatch.stop(self, _t, "", Stopwatch.Milliseconds)
func _on_BtnLoadAutosave_pressed():
	Debug.load_testing_save()

var prev_tile_test_value = 2
func _on_BtnTestTerrainImages_value_changed(value):
	var found = 0
	for y in Map.get_grid_size():
		for x in Map.get_grid_size():
			if Map.TILEMAP_FLAT.get_cell(x, y) == 2:
				Map.TILEMAP_FLAT.set_cell(x, y, prev_tile_test_value)
			if Map.TILEMAP_FLAT.get_cell(x, y) == value:
				Map.TILEMAP_FLAT.set_cell(x, y, 2)
				found += 1
	print("found: ", found, " cells")
	prev_tile_test_value = value
func _on_BtnRedrawMap_pressed():
	Map.redraw()
func _on_BtnTestSprites_value_changed(value): # BUG: this double-sets when pressing ENTER on a new number, oh WELL. not worth the trouble fixing it.
#	if value == $DEBUG_BTNS/BtnTestSprites.value:
	if value == -1:
		$TextureRect.texture = null
		return
#	get_tree().set_input_as_handled()
#	$TextureRect.texture = Assets.get_SG_texture("Pharaoh_Terrain.sg3", value)
#	print(value)
#	$TextureRect.texture = Assets.get_gameset_sg_texture(value)
	$TextureRect.texture = Assets.get_tagged_sg_texture("SprMain.sg3", value, 0, false)
#func _on_BtnTestSprites_gui_input(event):
#	if event is InputEventKey:
#		if event.pressed && (event as InputEventKey).scancode == KEY_ENTER:
#			$TextureRect.texture = Assets.get_gameset_sg_texture($DEBUG_BTNS/BtnTestSprites.value)

func _on_BtnChangeFPS_value_changed(value):
	Engine.target_fps = value
func _on_ToggleVsync_toggled(button_pressed):
	OS.vsync_enabled = button_pressed


var test_scribe_enabled = false
var test_scribe_temp = {
	"a": 0
}
var test_scribe_stamps = [
	0, 0, 0, 0, 0, 0,    0, 0, 0,
	0, 0, 0, 0, 0, 0,    0, 0, 0,
	0, 0, 0,
	0, 0, 0, 0, 0, 0,    0, 0, 0,
	0, 0, 0, 0, 0, 0,    0, 0, 0,
]
var test_scribe_indiv_i = [
	0, 0, 0, 0, 0, 0,    0, 0, 0,
	0, 0, 0, 0, 0, 0,    0, 0, 0,
	0, 0, 0,
	0, 0, 0, 0, 0, 0,    0, 0, 0,
	0, 0, 0, 0, 0, 0,    0, 0, 0,
]
var test_scribe_formats = [
	ScribeFormat.u8, ScribeFormat.i8, ScribeFormat.u16, ScribeFormat.i16, ScribeFormat.u32, ScribeFormat.i32, ScribeFormat.ascii, ScribeFormat.utf8, ScribeFormat.raw,
	ScribeFormat.u8, ScribeFormat.i8, ScribeFormat.u16, ScribeFormat.i16, ScribeFormat.u32, ScribeFormat.i32, ScribeFormat.ascii, ScribeFormat.utf8, ScribeFormat.raw,
	0, 0, 0,
	ScribeFormat.u8, ScribeFormat.i8, ScribeFormat.u16, ScribeFormat.i16, ScribeFormat.u32, ScribeFormat.i32, ScribeFormat.ascii, ScribeFormat.utf8, ScribeFormat.raw,
	ScribeFormat.u8, ScribeFormat.i8, ScribeFormat.u16, ScribeFormat.i16, ScribeFormat.u32, ScribeFormat.i32, ScribeFormat.ascii, ScribeFormat.utf8, ScribeFormat.raw,
]
var test_scribe_i = 0
func _on_BtnTestScribe_toggled(button_pressed):
	test_scribe_enabled = button_pressed
	if !test_scribe_enabled:
		Scribe.close()
func _on_BtnTestScribe2_pressed():
	for i in test_scribe_stamps.size():
		test_scribe_stamps[i] = 0
	for i in test_scribe_indiv_i.size():
		test_scribe_indiv_i[i] = 0
	test_scribe_i = 0
	DEBUG_LABEL4.text = "-"
func test_scribe_perform_random(i):
	var format = test_scribe_formats[i]
	if format == ScribeFormat.ascii || format == ScribeFormat.utf8 || format == ScribeFormat.raw:
#		test_scribe_indiv_i[i] = 1
#		return # ignore these for now
		
		
		var _t = Stopwatch.start()
		Scribe.put(format, "a", 64)
		test_scribe_stamps[i] += Stopwatch.query(_t, Stopwatch.Microsecond)
	else:
		var _t = Stopwatch.start()
		Scribe.put(format, "a")
		test_scribe_stamps[i] += Stopwatch.query(_t, Stopwatch.Microsecond)
	test_scribe_indiv_i[i] += 1
func test_scribe_get_r(i):
	if i == 18 || i == 19 || i == 20:
		return float(test_scribe_stamps[i]) / float(test_scribe_i)
	else:
		return float(test_scribe_stamps[i]) / float(test_scribe_indiv_i[i])
func test_scribe():
	
	if ScribeMono._path != "res://tests/autosave.sav":
		if !Scribe.open(File.READ, "res://tests/autosave.sav"):
			return false
	
	Scribe.sync_record([self, "test_scribe_temp"], TYPE_DICTIONARY)
	
	# MAIN TEST LOOP
	for i in 4:
		var _t = Stopwatch.start()
		ScribeMono.Seek(0)
		test_scribe_stamps[20] += Stopwatch.query(_t, Stopwatch.Microsecond)
		
		for a in (10):
			for j in range(0, 9): ## SCRIBE
				test_scribe_perform_random(j)
			for j in range(21, 30): ## SCRIBE.MONO
				test_scribe_perform_random(j)
		
		###########################
		_t = Stopwatch.start()
		ScribeMono.Seek(6012)
		test_scribe_stamps[20] += Stopwatch.query(_t, Stopwatch.Microsecond)
		
		_t = Stopwatch.start()
		Scribe.push_compressed(207936)
		test_scribe_stamps[18] += Stopwatch.query(_t, Stopwatch.Microsecond)
		###########################
		
		for a in (10):
			for j in range(9, 18): ## SCRIBE
				test_scribe_perform_random(j)
			for j in range(30, 39): ## SCRIBE.MONO
				test_scribe_perform_random(j)
		
		
		_t = Stopwatch.start()
		Scribe.pop_compressed()
		test_scribe_stamps[19] += Stopwatch.query(_t, Stopwatch.Microsecond)
#		test_scribe_stamps[18] += 1
#		test_scribe_stamps[19] += 1
#		test_scribe_stamps[20] += 1
		test_scribe_i += 1
		
	
	if !test_scribe_enabled:
		Scribe.close()
	else:
		var text =     "i:%-12d RAW               COMPR\n" % [test_scribe_i]
#		text += "               RAW / COMPR      RAW / COMPR\n"
#		text += "Scribe:u8      %-5.1f %-5.1f      %-5.1f %-5.1f\n" % [test_scribe_get_r(0), test_scribe_get_r(9), test_scribe_get_r(21), test_scribe_get_r(30)]
#		text += "Scribe:i8      %-5.1f %-5.1f      %-5.1f %-5.1f\n" % [test_scribe_get_r(1), test_scribe_get_r(10), test_scribe_get_r(22), test_scribe_get_r(31)]
#		text += "Scribe:u16     %-5.1f %-5.1f      %-5.1f %-5.1f\n" % [test_scribe_get_r(2), test_scribe_get_r(11), test_scribe_get_r(23), test_scribe_get_r(32)]
#		text += "Scribe:i16     %-5.1f %-5.1f      %-5.1f %-5.1f\n" % [test_scribe_get_r(3), test_scribe_get_r(12), test_scribe_get_r(24), test_scribe_get_r(33)]
#		text += "Scribe:u32     %-5.1f %-5.1f      %-5.1f %-5.1f\n" % [test_scribe_get_r(4), test_scribe_get_r(13), test_scribe_get_r(25), test_scribe_get_r(34)]
#		text += "Scribe:i32     %-5.1f %-5.1f      %-5.1f %-5.1f\n" % [test_scribe_get_r(5), test_scribe_get_r(14), test_scribe_get_r(26), test_scribe_get_r(35)]
#		text += "Scribe:ascii   %-5.1f %-5.1f      %-5.1f %-5.1f\n" % [test_scribe_get_r(6), test_scribe_get_r(15), test_scribe_get_r(27), test_scribe_get_r(36)]
#		text += "Scribe:utf8    %-5.1f %-5.1f      %-5.1f %-5.1f\n" % [test_scribe_get_r(7), test_scribe_get_r(16), test_scribe_get_r(28), test_scribe_get_r(37)]
#		text += "Scribe:raw     %-5.1f %-5.1f      %-5.1f %-5.1f\n" % [test_scribe_get_r(8), test_scribe_get_r(17), test_scribe_get_r(29), test_scribe_get_r(38)]
		
		text += "Scribe:u8      %-5.3f             %-5.3f\n" % [test_scribe_get_r(0), test_scribe_get_r(9)]
		text += "Scribe:i8      %-5.3f             %-5.3f\n" % [test_scribe_get_r(1), test_scribe_get_r(10)]
		text += "Scribe:u16     %-5.3f             %-5.3f\n" % [test_scribe_get_r(2), test_scribe_get_r(11)]
		text += "Scribe:i16     %-5.3f             %-5.3f\n" % [test_scribe_get_r(3), test_scribe_get_r(12)]
		text += "Scribe:u32     %-5.3f             %-5.3f\n" % [test_scribe_get_r(4), test_scribe_get_r(13)]
		text += "Scribe:i32     %-5.3f             %-5.3f\n" % [test_scribe_get_r(5), test_scribe_get_r(14)]
		text += "Scribe:ascii   %-5.3f             %-5.3f\n" % [test_scribe_get_r(6), test_scribe_get_r(15)]
		text += "Scribe:utf8    %-5.3f             %-5.3f\n" % [test_scribe_get_r(7), test_scribe_get_r(16)]
		text += "Scribe:raw     %-5.3f             %-5.3f\n" % [test_scribe_get_r(8), test_scribe_get_r(17)]
		text += "\n"
		text += "push_compressed   %d\n" % [test_scribe_get_r(18)]
		text += "pop_compressed    %d\n" % [test_scribe_get_r(19)]
		text += "File.seek         %d\n" % [test_scribe_get_r(20)]
		
		DEBUG_LABEL4.text = text
		
		
		if test_scribe_i >= 10000:
			$DEBUG_LABEL4/BtnTestScribe.pressed = false

onready var DEBUG_FPS = $DEBUG_FPS
onready var DEBUG_LABEL = $DEBUG_LABEL
onready var DEBUG_LABEL2 = $DEBUG_LABEL2
onready var DEBUG_LABEL3 = $DEBUG_LABEL3
onready var DEBUG_LABEL4 = $DEBUG_LABEL4
onready var DEBUG_LABEL5 = $DEBUG_LABEL5

onready var FONT_BASIS33 = load("res://assets/fonts/basis33_thick_outline.tres") as Font
onready var CURSOR = Game.INGAME_ROOT.get_node("CURSOR")
enum DebugDisplays {
	GRIDS = 0,
	TILEMAPS = 1,
#	FIGURES = 2,
#	BUILDINGS = 3,
}
var debug_display_mode = 1
func print_tile_debug():
	var mouse_pos = Game.INGAME_ROOT.get_local_mouse_position()
	var raw_tileset_space = Map.TILEMAP_FLAT.world_to_map(mouse_pos)
	raw_tileset_space.x = clamp(raw_tileset_space.x, 0, Map.get_grid_size() - 1)
	raw_tileset_space.y = clamp(raw_tileset_space.y, 0, Map.get_grid_size() - 1)
	CURSOR.position = Map.TILEMAP_FLAT.map_to_world(raw_tileset_space) # TODO: move do InGame / separate Cursor logic
	
	var tile = GameTile.new(Map.correct_orientation(raw_tileset_space), false)
	
	var debug_text = ""
	if Rect2(0, 0, Map.get_grid_size(), Map.get_grid_size()).has_point(tile.grid_Vector2):
		CURSOR.show()
		$DEBUG_LABEL3.show()
		
		debug_text += "grid: %s\n" % [tile.grid_Vector2]
		debug_text += "map: %s\n" % [tile.map_Vector2]
		match debug_display_mode:
			DebugDisplays.GRIDS:
				debug_text += "[color=#ffcc00]image:[/color]      %d\n" % [Map.grids.images.Get(tile.grid_x, tile.grid_y)]
				debug_text += "[color=#ffcc00]buildings:[/color]  %d\n" % [Map.grids.buildings.Get(tile.grid_x, tile.grid_y)]
				
				# terrain
				var _terrain = Map.grids.terrain.Get(tile.grid_x, tile.grid_y)
				debug_text += "[color=#ffcc00]terrain:[/color]    %d\n" % [_terrain]
				for flag in Map.TerrainFlags:
					if _terrain & Map.TerrainFlags[flag]:
						debug_text += "  [color=#888888]%s[/color]\n" % [flag]
						
				# edge
				var _edge = Map.grids.edge.Get(tile.grid_x, tile.grid_y)
				debug_text += "[color=#ffcc00]edge:[/color]       %d\n" % [_edge]
				if _terrain & Map.TerrainFlags.BUILDING == Map.TerrainFlags.BUILDING:
					for i in 6:
						var flag = str("ROW_", i)
						if _edge & Map.EdgeFlags.MASK_ROW == Map.EdgeFlags[flag]:
							debug_text += "  [color=#888888]%s[/color]\n" % [flag]
					for i in 6:
						var flag = str("COLUMN_", i)
						if _edge & Map.EdgeFlags.MASK_COLUMN == Map.EdgeFlags[flag]:
							debug_text += "  [color=#888888]%s[/color]\n" % [flag]
				if _edge & Map.EdgeFlags.DRAW_TILE == Map.EdgeFlags.DRAW_TILE:
					debug_text += "  [color=#888888]DRAW_TILE[/color]\n"
				if _edge & Map.EdgeFlags.NATIVE_LAND == Map.EdgeFlags.NATIVE_LAND:
					debug_text += "  [color=#888888]NATIVE_LAND[/color]\n"
						
				# bitfields
				var _bitfields = Map.grids.bitfields.Get(tile.grid_x, tile.grid_y)
				debug_text += "[color=#ffcc00]bitfields:[/color]  %d\n" % [_bitfields]
				if _terrain & Map.TerrainFlags.BUILDING == Map.TerrainFlags.BUILDING:
					for i in 8:
						var flag = str("SIZE_", i + 1)
						if _bitfields & Map.BitFlags.MASK_SIZE == Map.BitFlags[flag]:
							debug_text += "  [color=#888888]%s[/color]\n" % [flag]
				for flag in Map.BitFlags:
					if _bitfields & Map.BitFlags[flag] in [16, 32, 64, 128]:
						debug_text += "  [color=#888888]%s[/color]\n" % [flag]
			DebugDisplays.TILEMAPS:
				debug_text += "[color=#ccff00]Map_Flat:[/color]       %d\n" % [Map.TILEMAP_FLAT.get_cell(tile.grid_x, tile.grid_y)]
				debug_text += "[color=#ccff00]Map_Features:[/color]   %d\n" % [Map.TILEMAP_FEATURES.get_cell(tile.grid_x, tile.grid_y)]
				debug_text += "[color=#ccff00]Map_Top:[/color]        %d\n" % [Map.TILEMAP_TOP.get_cell(tile.grid_x, tile.grid_y)]
				debug_text += "[color=#ccff00]Map_Anim:[/color]       %d\n" % [Map.TILEMAP_ANIM.get_cell(tile.grid_x, tile.grid_y)]
#			DebugDisplays.FIGURES:
#				var figure_id_on_tile = Map.grids.figures[grid_coords.y][grid_coords.x]
#				if figure_id_on_tile != 0:
#					debug_text += "[color=#ccff00]ID:[/color]           %d\n" % [figure_id_on_tile]
#					var figure = Figures.figures[figure_id_on_tile]
#					var type = figure.get("type")
#					var type_name = CS_ENUMS.FigureTypes.get(type, null)
#					if type_name != null:
#						debug_text += "[color=#ccff00]Type:[/color]         %d:%s\n" % [type, type_name]
#					else:
#						debug_text += "[color=#ccff00]Type:[/color]         [color=#dd0000]%d:??[/color]\n" % [type]
#			DebugDisplays.BUILDINGS:
#				var building_id_on_tile = Map.grids.buildings[grid_coords.y][grid_coords.x]
#				if building_id_on_tile != 0:
#					debug_text += "[color=#ccff00]ID:[/color]           %d\n" % [building_id_on_tile]
#					var building = Buildings.buildings[building_id_on_tile]
#					var type = building.get("type")
#					var type_name = CS_ENUMS.BuildingTypes.get(type, null)
#					if type_name != null:
#						debug_text += "[color=#ccff00]Type:[/color]         %d:%s\n" % [type, type_name]
#					else:
#						debug_text += "[color=#ccff00]Type:[/color]         [color=#dd0000]%d:??[/color]\n" % [type]
				
				
#				debug_text += "[color=#ccff00]Map_Flat:[/color]       %d\n" % [figure_id_on_tile]
#
#				debug_text += "[color=#ccff00]Map_Features:[/color]   %d\n" % [Map.TILEMAP_FEATURES.get_cell(grid_coords.x, grid_coords.y)]
#				debug_text += "[color=#ccff00]Map_Top:[/color]        %d\n" % [Map.TILEMAP_TOP.get_cell(grid_coords.x, grid_coords.y)]
#				debug_text += "[color=#ccff00]Map_Anim:[/color]       %d\n" % [Map.TILEMAP_ANIM.get_cell(grid_coords.x, grid_coords.y)]
				
		
		if $DEBUG_LABEL3.bbcode_text != debug_text:
			$DEBUG_LABEL3.bbcode_text = debug_text
		$DEBUG_LABEL3.rect_position = $DEBUG_LABEL3.get_global_mouse_position() - Vector2(220, 170)
			
	else:
		CURSOR.hide()
		$DEBUG_LABEL3.hide()

	# figures
	debug_text = "[color=#ffff00]Figures:   %4d/%d                           \n[/color]" % [Figures._in_use, Figures.MAX_FIGURES]
#	var figure_id_on_tile = Map.grids.figures[tile.grid_y][tile.grid_x]
	var figure_id_on_tile = Map.grids.figures.Get(tile.grid_x, tile.grid_y)
	if figure_id_on_tile != 0:
		debug_text += "  [color=#ffff00]ID:[/color]           %d\n" % [figure_id_on_tile]
		var figure = Figures.figures[figure_id_on_tile]
		var type = figure.get("type") # + rand_seed(Game.tick)[0] % 50
		debug_text += "  [color=#ffff00]Type:[/color]         %s\n" % [Debug.enum_print_bbcode(Debug.CS_ENUMS.FigureTypes, type)]
	
	# buildings
	debug_text += "[color=#00ffcc]Buildings: %4d/%d\n[/color]" % [Buildings._in_use, Buildings.MAX_BUILDINGS]
#	var building_id_on_tile = Map.grids.buildings[tile.grid_y][tile.grid_x]
	var building_id_on_tile = Map.grids.buildings.Get(tile.grid_x, tile.grid_y)
	if building_id_on_tile != 0:
		debug_text += "  [color=#00ffcc]ID:[/color]           %d\n" % [building_id_on_tile]
		var building = Buildings.buildings[building_id_on_tile]
		var type = building.get("type")
		debug_text += "  [color=#00ffcc]Type:[/color]         %s\n" % [Debug.enum_print_bbcode(Debug.CS_ENUMS.BuildingTypes, type)]
	
	if $DEBUG_LABEL5.bbcode_text != debug_text:
		$DEBUG_LABEL5.bbcode_text = debug_text
	
var ingame_camera_has_moved = false
func _input(event):
	
	if Input.is_action_just_pressed("ui_accept"):
		if $DEBUG_BTNS/BtnTestSprites.has_focus() || $DEBUG_BTNS/BtnTestSprites.get_child(0).has_focus():
			_on_BtnTestSprites_value_changed($DEBUG_BTNS/BtnTestSprites.value)
	
	# copy to cliboard DEBUG_LABEL4 test results...
	if Input.is_key_pressed(KEY_CONTROL) && Input.is_key_pressed(KEY_C) && DEBUG_LABEL4.has_focus():
		var selection = DEBUG_LABEL4.get_selected_text()
		OS.clipboard = selection
		print(selection)
	
	# extra debugging
	if Input.is_action_just_pressed("debug_toggle"):
		visible = !visible
		CURSOR.visible = visible
	if Input.is_action_just_pressed("debug_cycle"):
		if visible:
			if Input.is_key_pressed(KEY_SHIFT):
				debug_display_mode = (debug_display_mode - 1) % DebugDisplays.keys().size()
			else:
				debug_display_mode = (debug_display_mode + 1) % DebugDisplays.keys().size()

func print_friendly(thing, padding = ""):
	if thing is Vector2:
		return "(%.02f, %.02f)" % [thing.x, thing.y]
	if thing is Vector3:
		return "(%.02f, %.02f, %.02f)" % [thing.x, thing.y, thing.z]
	if thing is Array:
		var content = ""
		for child in thing:
			content += "%s%s" % [", " if content != "" else "", print_friendly(child, padding)]
		return "[%s]" % [content]
	if thing is Dictionary: # this is INDENTED.... 
		var content = ""
		for key in thing:
			content += "%s%s%s: %s" % [",\n" if content != "" else "\n", padding + "    ", key, print_friendly(thing[key], padding + "    ")]
		return "{%s\n%s}" % [content, padding]
	return "%s" % [thing]
func _process(delta):
	
	if Game.STATE == Game.States.NoGameLoaded:
		$DEBUG_LABEL.hide()
		$DEBUG_LABEL3.hide()
		$DEBUG_LABEL5.hide()
		return
	else:
		$DEBUG_LABEL.show()
		$DEBUG_LABEL3.show()
		$DEBUG_LABEL5.show()
	
	if test_scribe_enabled:
		test_scribe()
	
	
	# debug prints
#	var col1 = "[color=#888888]"
	var col1 = "[color=#a8a8a8]"
	var debug_text = col1 + "Ozymandias Godot3.6 v0.2[/color]\n"
	debug_text += col1 + "debug_display_mode:[/color]  %d:%s\n" % [debug_display_mode, Log.get_enum_string(DebugDisplays, debug_display_mode)]
	debug_text += col1 + "game_state:[/color]          %s\n" % [Log.get_enum_string(Game.States, Game.STATE)]
	debug_text += col1 + "last_menu:[/color]           %s\n" % [Game.debug_last_menu]
	debug_text += col1 + "current_family:[/color]      %s\n" % [Family.current_family]
	debug_text += col1 + "families:[/color]            %s\n\n" % [Family.data.size()]
	#
	debug_text += col1 + "camera:[/color]              %s\n" % [print_friendly(Game.INGAME_ROOT.camera_position_target)]
	debug_text += col1 + "zoom:[/color]                %s\n" % [print_friendly(Game.INGAME_ROOT.camera_zoom_target)]
	debug_text += col1 + "mouse_worldpos:[/color]      %s\n" % [print_friendly(Game.INGAME_ROOT.mouse_worldpos)]
	debug_text += col1 + "curr_click_mouse:[/color]    %s\n" % [print_friendly(Game.INGAME_ROOT.current_click_game_coords)]
	debug_text += col1 + "last_click_mouse:[/color]    %s\n" % [print_friendly(Game.INGAME_ROOT.last_click_game_coords)]
	debug_text += col1 + "last_click_camera:[/color]   %s\n" % [print_friendly(Game.INGAME_ROOT.camera_previous_game_coords)]
	debug_text += col1 + "orientation:[/color]         %s\n\n" % [Debug.enum_print_bbcode(Debug.CS_ENUMS.Directions, Map.city_orientation)]
#	debug_text += col1 + "\n\n\n\n\ntest:[/color]    \n%s\n\n" % [print_friendly({"aa": 2, "fdyt": [1,2], "b": {"aa": 2, "fdyt": [1,2]}})]
	#
	debug_text += col1 + "game_speed:[/color]   %d\n" % [Game.speed]
	debug_text += col1 + "ENGINE_t:[/color]     %.2f\n" % [Game.t]
	debug_text += col1 + "refresh_rate:[/color] %.2f\n" % [Game.game_refresh_rate]
	debug_text += col1 + "TPS:[/color]          %.2f\n" % [Game.speed_tps]
	debug_text += col1 + "ticks/frame:[/color]  %.2f\n" % [Game.ticks_per_frame]
	debug_text += col1 + "ticks_to_do:[/color]  %.2f\n\n" % [Game.ticks_to_do]
	#
	debug_text += col1 + "total_ticks:[/color]  %d\n" % [Game.total_ticks]
	debug_text += col1 + "total_days:[/color]   %d\n" % [Game.total_days]
	debug_text += col1 + "tick:[/color]         %d\n" % [Game.tick]
	debug_text += col1 + "day:[/color]          %d\n" % [Game.day]
	debug_text += col1 + "month:[/color]        %d\n" % [Game.month]
	debug_text += col1 + "year:[/color]         %d\n\n" % [Game.year]
	#
	
	if DEBUG_LABEL.bbcode_text != debug_text:
		DEBUG_LABEL.bbcode_text = debug_text
	
	DEBUG_FPS.text = str(Game.last_fps, " FPS")
	
	print_tile_debug()

func _ready():
	$DEBUG_LABEL3.bbcode_text = ""



