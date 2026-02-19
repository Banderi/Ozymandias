extends CanvasLayer
	
func _on_BtnPKWareTest_pressed():
	Game.do_PKWare_tests()
func _on_BtnLoadAutosave_pressed():
	Game.load_game("res://tests/autosave.sav")
#	Game.load_game("res://tests/Alexandria.sav")

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

func _on_BtnRedrawMap_pressed():
	Map.redraw()

func _on_BtnTestSprites_value_changed(value):
#	get_tree().set_input_as_handled()
#	$TextureRect.texture = Assets.get_sg_texture("Pharaoh_Terrain.sg3", value)
	$TextureRect.texture = Assets.get_gameset_sg_texture(value)

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
			for j in range(0,9): ## SCRIBE
				test_scribe_perform_random(j)
			for j in range(21,30): ## SCRIBE.MONO
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
			for j in range(9,18): ## SCRIBE
				test_scribe_perform_random(j)
			for j in range(30,39): ## SCRIBE.MONO
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

onready var FONT_BASIS33 = load("res://assets/fonts/basis33_thick_outline.tres") as Font
onready var CURSOR = Game.INGAME_ROOT.get_node("CURSOR")
enum DebugDisplays {
	GRIDS = 0,
	TILEMAPS = 1,
	FIGURES = 2,
	BUILDINGS = 3,
}
var debug_display_mode = 1
func present_debug():
	var mouse_pos = Game.INGAME_ROOT.get_local_mouse_position()
	var tile_coords = Map.TILEMAP_FLAT.world_to_map(mouse_pos)
	CURSOR.position = Map.TILEMAP_FLAT.map_to_world(tile_coords) # TODO: move do InGame / separate Cursor logic
	
	var tile_text = ""
	if Rect2(0, 0, Map.PH_MAP_WIDTH, Map.PH_MAP_WIDTH).has_point(tile_coords):
		CURSOR.show()
		$DEBUG_LABEL3.show()
		
		match debug_display_mode:
			DebugDisplays.GRIDS:
				tile_text += "tile: %s\n" % [tile_coords]
				tile_text += "[color=#ffcc00]image:[/color]      %d\n" % [Map.grids.images[tile_coords.y][tile_coords.x]]
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
			DebugDisplays.TILEMAPS:
				tile_text += "tile: %s\n" % [tile_coords]
				tile_text += "[color=#ccff00]Map_Flat:[/color]       %d\n" % [Map.TILEMAP_FLAT.get_cell(tile_coords.x, tile_coords.y)]
				tile_text += "[color=#ccff00]Map_Features:[/color]   %d\n" % [Map.TILEMAP_FEATURES.get_cell(tile_coords.x, tile_coords.y)]
				tile_text += "[color=#ccff00]Map_Top:[/color]        %d\n" % [Map.TILEMAP_TOP.get_cell(tile_coords.x, tile_coords.y)]
				tile_text += "[color=#ccff00]Map_Anim:[/color]       %d\n" % [Map.TILEMAP_ANIM.get_cell(tile_coords.x, tile_coords.y)]
				
		
		if $DEBUG_LABEL3.bbcode_text != tile_text:
			$DEBUG_LABEL3.bbcode_text = tile_text
		$DEBUG_LABEL3.rect_position = $DEBUG_LABEL3.get_global_mouse_position() - Vector2(220, 170)
			
	else:
		CURSOR.hide()
		$DEBUG_LABEL3.hide()

	
#	# stylebox
#	var long = ""
#	var lon = 0
#	var lines = $DEBUG_LABEL3.text.split("\n")
#	for l in lines:
#		if l.length() > lon:
#			lon = l.length()
#			long = l
#	var box = $DEBUG_LABEL3.get_stylebox("normal")
#	$DEBUG_LABEL3.rect_size.x = FONT_BASIS33.get_string_size(long).x + box.content_margin_left + box.content_margin_right
#	$DEBUG_LABEL3.rect_size.y = (lines.size() - 1) * (FONT_BASIS33.get_height() + $DEBUG_LABEL3.get("custom_constants/line_separation")) +\
#		box.content_margin_top + box.content_margin_bottom


func _input(event):
	
	if Input.is_key_pressed(KEY_CONTROL) && Input.is_key_pressed(KEY_C) && DEBUG_LABEL4.has_focus():
		var selection = DEBUG_LABEL4.get_selected_text()
		OS.clipboard = selection
		print(selection)
	
	if Input.is_action_just_pressed("debug_toggle"):
		visible = !visible
		CURSOR.visible = visible
		if visible:
			present_debug()
#		Input.parse_input_event(InputEventAction.new())
	if Input.is_action_just_pressed("debug_cycle"):
		if visible:
			debug_display_mode = (debug_display_mode + 1) % 3
			present_debug()
	
	if visible && Game.STATE != Game.States.MainMenu:
		if event is InputEventMouseMotion:
			present_debug()

var last_fps = 60
func _process(delta):
	
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
	debug_text += col1 + "camera:[/color]              %s\n" % [Game.INGAME_ROOT.camera_position_target]
	debug_text += col1 + "zoom:[/color]                %s\n" % [Game.INGAME_ROOT.camera_zoom_target]
	debug_text += col1 + "mouse_worldpos:[/color]      %s\n" % [Game.INGAME_ROOT.mouse_worldpos]
	debug_text += col1 + "curr_click_mouse:[/color]    %s\n" % [Game.INGAME_ROOT.current_click_game_coords]
	debug_text += col1 + "last_click_mouse:[/color]    %s\n" % [Game.INGAME_ROOT.last_click_game_coords]
	debug_text += col1 + "last_click_camera:[/color]   %s\n\n" % [Game.INGAME_ROOT.camera_previous_game_coords]
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
	debug_text += col1 + "year:[/color]         %d\n" % [Game.year]
	
	if DEBUG_LABEL.bbcode_text != debug_text:
		DEBUG_LABEL.bbcode_text = debug_text
	
	last_fps = Engine.get_frames_per_second()
	DEBUG_FPS.text = str(last_fps, " FPS")

func _ready():
	$DEBUG_LABEL3.bbcode_text = ""




