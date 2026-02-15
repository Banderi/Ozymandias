extends Node

const INDUSTRY_RESOURCES = 36

onready var ROOT_NODE = get_tree().root.get_node("Root")
onready var INGAME_ROOT = ROOT_NODE.get_node("InGame")
onready var MENUS_ROOT = ROOT_NODE.get_node("Menus")
onready var DEBUG_ROOT = ROOT_NODE.get_node("Debug")

onready var TEST_SPR_ATLAS = ROOT_NODE.get_node("TEST_SPR_ATLAS")

# generics
func is_valid_objref(node):
	if node != null && !(!weakref(node).get_ref()):
		return true
	return false

# MENUS
var debug_last_menu = null
func go_to_menu(menu_name, data = null):
	var menu_node = MENUS_ROOT.get_node_or_null(menu_name)
	if menu_node == null:
		Log.error(self, GlobalScope.Error.ERR_DOES_NOT_EXIST, "menu '%s' is invalid" % [menu_name])
		return
	close_all_menus()
	if menu_node.has_method("_on_menu_open"):
		menu_node._on_menu_open(data)
	debug_last_menu = menu_name
	menu_node.show()
func popup_menu(menu_name, data = null):
	var menu_node = MENUS_ROOT.get_node_or_null(menu_name)
	if menu_node == null:
		Log.error(self, GlobalScope.Error.ERR_DOES_NOT_EXIST, "menu '%s' is invalid" % [menu_name])
		return
	if menu_node.has_method("_on_menu_open"):
		menu_node._on_menu_open(data)
	debug_last_menu = menu_name
	menu_node.show()
func close_all_menus():
	for m in MENUS_ROOT.get_children():
		m.hide()
	debug_last_menu = null

func right_click_pressed(relevant_node, event): # TODO: capture right click when over ANY element of the currently open menu
	if event is InputEventMouseButton && event.button_index == BUTTON_RIGHT:
		return true
	return false

func debug_tools_enabled():
	return false

# PKWare inflate / deflate tests
const CHUNK_SIZE = 1024
func get_file_hash(path, type) -> String: #  SHA-256
	var ctx = HashingContext.new()
	var file = File.new()
	ctx.start(type)
	file.open(path, File.READ)
	while not file.eof_reached():
		ctx.update(file.get_buffer(CHUNK_SIZE))
	var res = ctx.finish()
	return res.hex_encode()
func get_hash(path) -> String:
	return get_file_hash(path, HashingContext.HASH_SHA256)
func passed(a, b):
	return "✓" if a == b else "X "
func do_PKWare_test(i, og_deflated: PoolByteArray, og_inflated: PoolByteArray):
	if i == 24:
		pass
	var hash_og_deflated = (og_deflated as Array).hash()
	var hash_og_inflated = (og_inflated as Array).hash()
	var hash_cs_deflated = (PKWareMono.Deflate(og_inflated, 4096) as Array).hash()
	var hash_cs_inflated = (PKWareMono.Inflate(og_deflated, og_inflated.size()) as Array).hash()
	print("%2d:   %012d %s  %012d %s" % [
		i,
		hash_cs_deflated, passed(hash_cs_deflated, hash_og_deflated),
		hash_cs_inflated, passed(hash_cs_inflated, hash_og_inflated)])
func do_PKWare_tests():
	print("      COMPRESSED       UNCOMPRESSED")
	print("-------------------------------------")
	var _t = Stopwatch.start()
	for i in range(0, 34):
		var file = File.new()
		file.open(str("res://../tests/d/", i), File.READ)
		var og_defl = file.get_buffer(file.get_len())
		file.open(str("res://../tests/i/", i), File.READ)
		var og_infl = file.get_buffer(file.get_len())
		file.close()
		do_PKWare_test(i, og_defl, og_infl)
	Stopwatch.stop(self, _t, "", Stopwatch.Milliseconds) # ~1150 ms ---> ~1100 ms
		
# ????????
var unkn_debug_00 = 0
var unkn_debug_01 = 0
var unkn_debug_02 = 0
var unkn_debug_03_a = 0
var unkn_debug_03_b = 0
var unkn_debug_04_a = 0
var unkn_debug_04_b = 0
var unk_05 = 0
var unk_06 = 0
var unused_figure_sequences = null
var unused_10_x_820 = null
var unk_junk14_a_1 = 0
var unk_junk14_a_2 = 0
var unk_junk14_a_3 = 0
var unk_junk14_a_4 = 0
var unk_junk14_b_1 = 0
var unk_junk14_b_2 = 0
var unk_junk14_b_3 = 0
var unk_junk14_b_4 = 0
var unk_junk18 = 0
var bizarre_ordered_fields_1 = null
var bizarre_ordered_fields_2 = null
var bizarre_ordered_fields_3 = null
var bizarre_ordered_fields_4 = null
var bizarre_ordered_fields_5 = null
var bizarre_ordered_fields_6 = null
var bizarre_ordered_fields_7 = null
var bizarre_ordered_fields_8 = null
var bizarre_ordered_fields_9 = null

#############

enum States {
	MainMenu,
	Ingame,
	Paused
}
var STATE = States.MainMenu
func load_game(path):
	if !IO.file_exists(path):
		Log.error(self, GlobalScope.Error.ERR_DOES_NOT_EXIST, "the savefile '%s' does not exist" % [path])
		return false
	else:
		if !Scribe.enscribe(path, File.READ, false, funcref(self, "enscribe_SAV")):
			return false
		
		Map.redraw()
		Figures.spawn_sprites()
		
		STATE = States.Ingame
		close_all_menus()
		
		return true
func save_game(path): # TODO
	if STATE == States.MainMenu:
		Log.error(self, GlobalScope.Error.ERR_LOCKED, "can not save without a game loaded first")
		return false
	else:
#		if !Scribe.enscribe(path, File.WRITE, false, funcref(self, "enscribe_SAV")):
#			return false
#		return true
		print("TODO: saving ------- ", path)

var debug_schema = { # default schema used
	"file_version": 160,
	"chunks_schema": -1,
	"chunks": []
}
func set_schema(): # TODO
	pass
func enscribe_schema():
	Scribe.sync_record([debug_schema], TYPE_DICTIONARY)
	Scribe.put(ScribeFormat.i32, "file_version")
	Scribe.put(ScribeFormat.i32, "chunks_schema")
	var chunks_beginning = Scribe._handle.get_position()
	for i in range(debug_schema.chunks_schema):
		var s = Scribe._handle.get_position()
		Scribe.sync_record([debug_schema, "chunks", i], TYPE_DICTIONARY)
		Scribe.put(ScribeFormat.u32, "compressed")
		Scribe.put(ScribeFormat.u8, "memory_offset")
		Scribe.put(ScribeFormat.u16, "memory_location")
		Scribe.put(ScribeFormat.u8, "unk03")
		Scribe.put(ScribeFormat.u32, "fields_size")
		Scribe.put(ScribeFormat.u32, "fields_num")
		Scribe.put(ScribeFormat.u16, "unk06")
		Scribe.put(ScribeFormat.u16, "unk07")
		assert(Scribe._handle.get_position() == s + 20)
		print("%03d: %s %6d %4d : %-6d %-5d %2d : %6d * %5d" % [
			i,
			"(C)" if debug_schema.chunks[i].compressed else "---",
			debug_schema.chunks[i].unk06, debug_schema.chunks[i].unk07,
			debug_schema.chunks[i].memory_location, debug_schema.chunks[i].memory_offset, debug_schema.chunks[i].unk03,
			debug_schema.chunks[i].fields_num, debug_schema.chunks[i].fields_size
		])
	Scribe._handle.seek(chunks_beginning + 300 * 20) # move to the end

func enscribe_SAV():
	Scribe.sync_record([Campaign.data, "headers"], TYPE_DICTIONARY) # TODO: move to "Scenario" singleton
	Scribe.put(ScribeFormat.u8, "map_index")
	Scribe.put(ScribeFormat.u8, "campaign_index")
	Scribe.put(ScribeFormat.i8, "prev_progress_pointer")
	Scribe.put(ScribeFormat.i8, "mission_progress_pointer")
	enscribe_schema()
	
#	Scribe.sync_record([Map.grids], TYPE_DICTIONARY)
	Scribe.put_grid(ScribeFormat.u32, "images", true)
	Scribe.put_grid(ScribeFormat.i8, "edge", true)
	Scribe.put_grid(ScribeFormat.i16, "buildings", true)
	Scribe.put_grid(ScribeFormat.u32, "terrain", true)
	Scribe.put_grid(ScribeFormat.u8, "aqueduct", true)
	Scribe.put_grid(ScribeFormat.u16, "figures", true)
	Scribe.put_grid(ScribeFormat.u8, "bitfields", true)
	Scribe.put_grid(ScribeFormat.u8, "sprites", true)
	Scribe.put_grid(ScribeFormat.u8, "random", false)
	Scribe.put_grid(ScribeFormat.u8, "desirability", true)
	Scribe.put_grid(ScribeFormat.u8, "elevation", true)
	Scribe.put_grid(ScribeFormat.i16, "building_dmg", true)
	Scribe.put_grid(ScribeFormat.u8, "aqueduct_bak", true)
	Scribe.put_grid(ScribeFormat.u8, "sprite_bak", true)
	
	Figures.enscribe_figures()
	
	Scribe.push_compressed(Figures.MAX_ROUTES * 2) # <---------------------------------- TODO
#	for i in Figures.MAX_ROUTES:
#		Scribe.sync_record([Figures.routes, i], TYPE_DICTIONARY)
#		pass
	Scribe.pop_compressed()
	Scribe.push_compressed(500000) # route paths cached data <-------------------- TODO
	Scribe.pop_compressed()
	
	# formations
	Scribe.push_compressed(Figures.MAX_FORMATIONS * 144) # <---------------------------- TODO
	Scribe.pop_compressed()
	Scribe.sync_record([Figures], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "last_used_formation")
	Scribe.put(ScribeFormat.i32, "last_formation_id")
	Scribe.put(ScribeFormat.i32, "total_formations")
	
	# city data
	Scribe.sync_record([City], TYPE_OBJECT)
	Scribe.push_compressed(37808) # <----------------------------- TODO
	Scribe.pop_compressed()
	Scribe.put(ScribeFormat.i16, "unused_faction_flags1")
	Scribe.put(ScribeFormat.i16, "unused_faction_flags2")
	Scribe.put(ScribeFormat.ascii, "player_name1", 32)
	Scribe.put(ScribeFormat.ascii, "player_name2", 32)
	Scribe.put(ScribeFormat.i32, "city_faction")
	
	# buildings
	Scribe.sync_record([Buildings], TYPE_OBJECT)
	Scribe.push_compressed(Buildings.MAX_BUILDINGS * 264) # <----------------------------- TODO
	Scribe.pop_compressed()
	
	# camera orientation
	Scribe.sync_record([Map], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "city_orientation")
	
	# game time
	Scribe.sync_record([self], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "tick")
	Scribe.put(ScribeFormat.i32, "day")
	Scribe.put(ScribeFormat.i32, "month")
	Scribe.put(ScribeFormat.i32, "year")
	Scribe.put(ScribeFormat.i32, "total_days")
	
	Scribe.sync_record([Buildings], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "highest_id_ever")
	
	Scribe.sync_record([Gods], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "tick_countdown_locusts")
	
	# random
	Scribe.sync_record([Random], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "random_iv_1")
	Scribe.put(ScribeFormat.i32, "random_iv_2")
	
	Scribe.sync_record([Map], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "city_view_camera_x")
	Scribe.put(ScribeFormat.i32, "city_view_camera_y")
	
	Scribe.sync_record([City], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "city_graph_order")
	
	Scribe.sync_record([Gods], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "tick_countdown_hailstorm")
	
	# empire
	Scribe.sync_record([Empire], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "empire_map_x")
	Scribe.put(ScribeFormat.i32, "empire_map_y")
	Scribe.put(ScribeFormat.i32, "empire_selected_object")
	Scribe.push_compressed(Empire.MAX_EMPIRE_CITIES * 106) # <----------------------------- TODO
	Scribe.pop_compressed()
	
	# industry buildings
	Scribe.sync_record([City, "industry_buildings_total"], TYPE_ARRAY)
	for i in INDUSTRY_RESOURCES:
		Scribe.put(ScribeFormat.i32, i)
	Scribe.sync_record([City, "industry_buildings_active"], TYPE_ARRAY)
	for i in INDUSTRY_RESOURCES:
		Scribe.put(ScribeFormat.i32, i)
	
	# trade prices
	for i in INDUSTRY_RESOURCES:
		Scribe.sync_record([Empire, "trade_prices", i], TYPE_DICTIONARY)
		Scribe.put(ScribeFormat.i32, "selling")
		Scribe.put(ScribeFormat.i32, "buying")
	
	# figure names (1)	
	Scribe.sync_record([Figures, "figure_names_1"], TYPE_ARRAY)
	for i in 21:
		Scribe.put(ScribeFormat.i32, i)
	
	# scenario data
	Scribe.sync_record([Scenario, "info"], TYPE_DICTIONARY)
	Scribe.put(ScribeFormat.raw, "TEMP_RAW", 1592) # <---------------------------- TODO
	Scribe.put(ScribeFormat.i32, "max_year")
	
	# messages
	Scribe.sync_record([Messages], TYPE_OBJECT)
	Scribe.push_compressed(Messages.MAX_MESSAGES * 48) # <----------------------------- TODO
	Scribe.pop_compressed()
	Scribe.put(ScribeFormat.i32, "total_messages_passed")
	Scribe.put(ScribeFormat.i32, "total_messages_current")
	Scribe.put(ScribeFormat.i32, "last_message_id_highlighted")
	Scribe.sync_record([Messages, "census_messages_received"], TYPE_ARRAY)
	for i in 10:
		Scribe.put(ScribeFormat.u8, i)
	Scribe.sync_record([Messages, "message_counts"], TYPE_ARRAY)
	for i in Messages.MESSAGE_CATEGORIES:
		Scribe.put(ScribeFormat.i32, i)
	Scribe.sync_record([Messages, "message_delays"], TYPE_ARRAY)
	for i in Messages.MESSAGE_CATEGORIES:
		Scribe.put(ScribeFormat.i32, i)
	
	# burning buildings
	Scribe.sync_record([Buildings], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "burning_buildings_list_info")
	Scribe.put(ScribeFormat.i32, "burning_buildings_size")
	
	Scribe.sync_record([Figures], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "figure_sequence")
	
	Scribe.sync_record([Scenario], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "starting_kingdom")
	Scribe.put(ScribeFormat.i32, "starting_savings")
	Scribe.put(ScribeFormat.i32, "starting_rank")
	Scribe.push_compressed(101 * 32) # <--------------------------------------------------- TODO
#	Scribe.put(ScribeFormat.i32, "invasion_warnings")
	Scribe.pop_compressed()
	Scribe.put(ScribeFormat.i32, "scenario_is_custom")
	
	# city sound channels
	Scribe.sync_record([Sounds, "city_sounds"], TYPE_OBJECT)
	for i in Sounds.MAX_CITY_SOUNDS:
		Scribe.put(ScribeFormat.raw, i, 128) # <------------------- TODO
	
	Scribe.sync_record([Buildings], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "highest_id")
	
	# traders
	Scribe.sync_record([Figures, "figure_traders"], TYPE_ARRAY)
	for i in Figures.MAX_TRADERS:
		Scribe.put(ScribeFormat.raw, i, 88)
	Scribe.sync_record([Figures], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "next_free_trader_index")

	# buildings lists
	Scribe.sync_record([Buildings], TYPE_OBJECT)
	Scribe.push_compressed(500 * 2) # building_list_burning# <--------------------------------------- TODO
	Scribe.pop_compressed()
	Scribe.push_compressed(500 * 2) # building_list_small# <--------------------------------------- TODO
	Scribe.pop_compressed()
	Scribe.push_compressed(Buildings.MAX_BUILDINGS * 2) # building_list_large# <--------------------------------------- TODO
	Scribe.pop_compressed()
	
	Scribe.sync_record([Scenario], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "is_campaign_mission_first")
	Scribe.put(ScribeFormat.i32, "is_campaign_mission_first_four")
	
	Scribe.sync_record([Figures, "figure_names_3"], TYPE_ARRAY)
	for i in 4:
		Scribe.put(ScribeFormat.i32, i)
	
	Scribe.sync_record([Gods], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "tick_countdown_frogs")
	Scribe.put(ScribeFormat.i32, "tick_countdown_pyramid_speedup")
	Scribe.put(ScribeFormat.i32, "tick_countdown_blood1")
	Scribe.put(ScribeFormat.raw, "unkn_06", 5*4) # ????
	
	Scribe.sync_record([Buildings, "storage_yards_settings"], TYPE_ARRAY)
	for i in Buildings.MAX_STORAGE_YARDS:
		Scribe.put(ScribeFormat.raw, i, 196) # <--------------------------------------- TODO
	
	Scribe.sync_record([Empire], TYPE_OBJECT)
	Scribe.push_compressed(Empire.MAX_TRADE_ROUTES * INDUSTRY_RESOURCES * 4) # trade_routes_limits <------------------ TODO
	Scribe.pop_compressed()
	Scribe.push_compressed(Empire.MAX_TRADE_ROUTES * INDUSTRY_RESOURCES * 4) # trade_routes_traded <------------------ TODO
	Scribe.pop_compressed()
	
	Scribe.sync_record([Military], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "working_towers")
	
	Scribe.sync_record([Buildings], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "creation_highest_id")
	
	Scribe.sync_record([Routing], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "routing_debug")

	## ============== unknown / debug stuff ============== ##
	Scribe.sync_record([self], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "unkn_debug_00")
	Scribe.put(ScribeFormat.i32, "unkn_debug_01")
	Scribe.put(ScribeFormat.i32, "unkn_debug_02")
	Scribe.put(ScribeFormat.i32, "unkn_debug_03_a")
	Scribe.put(ScribeFormat.i32, "unkn_debug_03_b")
	Scribe.put(ScribeFormat.i32, "unkn_debug_04_a")
	Scribe.put(ScribeFormat.i32, "unkn_debug_04_b")
	
	Scribe.sync_record([Military], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i16, "invasions_creation_sequence")
	
	Scribe.sync_record([Buildings], TYPE_OBJECT)
	Scribe.put(ScribeFormat.u32, "corrupt_house_coords_repaired")
	Scribe.put(ScribeFormat.u32, "corrupt_house_coords_deleted")
	
	Scribe.sync_record([Scenario], TYPE_OBJECT)
	Scribe.put(ScribeFormat.ascii, "scenario_map_name", 65)
	
	for i in Map.MAX_BOOKMARKS:
		Scribe.sync_record([Map, "bookmarks", i], TYPE_DICTIONARY)
		Scribe.put(ScribeFormat.i8, "x")
		Scribe.put(ScribeFormat.i8, "y")
	
	Scribe.sync_record([Gods], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "tick_countdown_blood2")

	# ============== ????
	Scribe.sync_record([self], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "unk_05")
	Scribe.put(ScribeFormat.i32, "unk_06")
	
	# ============== ????
	Scribe.sync_record([Scenario, "unk_fields"], TYPE_ARRAY)
	for i in 99:
		Scribe.put(ScribeFormat.i32, i)

	Scribe.put_grid(ScribeFormat.u8, "fertility", false)
	
	for i in Scenario.MAX_EVENTS:
		Scribe.sync_record([Scenario, "events", i], TYPE_DICTIONARY)
		Scribe.put(ScribeFormat.raw, "TEMP", 124) # <---------------------------- TODO
	Scribe.sync_record([Scenario, "events_extra"], TYPE_DICTIONARY)
	Scribe.put(ScribeFormat.i32, "unk00")
	Scribe.put(ScribeFormat.i32, "unk01")
	Scribe.put(ScribeFormat.i32, "unk02")
	Scribe.put(ScribeFormat.i32, "unk03")
	Scribe.put(ScribeFormat.i32, "unk04")
	Scribe.put(ScribeFormat.i32, "unk05")
	Scribe.put(ScribeFormat.i32, "unk06")
	
	# ferries
	for i in Figures.MAX_FERRIES:
		Scribe.sync_record([Figures, "ferry_queues", i], TYPE_ARRAY)
		for j in Figures.MAX_FIGURES_WAITING_PER_FERRY:
			Scribe.put(ScribeFormat.i32, j)
	for i in Figures.MAX_FERRIES:
		Scribe.sync_record([Figures, "ferry_transiting", i], TYPE_ARRAY)
		for j in Figures.MAX_FIGURES_PER_FERRY:
			Scribe.put(ScribeFormat.i32, j)
	
	# ============== ????
	Scribe.sync_record([self], TYPE_OBJECT)
	Scribe.put(ScribeFormat.raw, "unused_figure_sequences", 4 * 4)
	Scribe.put(ScribeFormat.raw, "unused_10_x_820", 10 * 820)
	
	Scribe.sync_record([Empire], TYPE_OBJECT)
	Scribe.push_compressed(40 * 32) # unused multiple-empires leftover stuff from C3
	Scribe.pop_compressed()
	Scribe.push_compressed(Empire.MAX_MAP_OBJECTS * 98) # empire_map_objects <-------------------------------- TODO
	Scribe.pop_compressed()
	Scribe.push_compressed(Empire.MAX_EMPIRE_ROUTES * 324) # empire_map_routes <-------------------------------- TODO
	Scribe.pop_compressed()
	
	Scribe.put_grid(ScribeFormat.u8, "vegetation_growth", false)
	
	# ============== ????
	Scribe.sync_record([self], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "unk_junk14_a_1")
	Scribe.put(ScribeFormat.i32, "unk_junk14_a_2")
	Scribe.put(ScribeFormat.i32, "unk_junk14_a_3")
	Scribe.put(ScribeFormat.i32, "unk_junk14_a_4")
	Scribe.put(ScribeFormat.u8, "unk_junk14_b_1")
	Scribe.put(ScribeFormat.u8, "unk_junk14_b_2")
	Scribe.put(ScribeFormat.u8, "unk_junk14_b_3")
	Scribe.put(ScribeFormat.u8, "unk_junk14_b_4")
	Scribe.put(ScribeFormat.raw, "bizarre_ordered_fields_1", 22 * 24)
	
	# floodplain data
	Scribe.push_compressed(36) # floodplain_settings <-------------------------------- TODO
	Scribe.pop_compressed()
	
	Scribe.put_grid(ScribeFormat.i32, "unk_grid03", true) # routing cache...?
	
	
	Scribe.sync_record([self], TYPE_OBJECT)
	Scribe.put(ScribeFormat.raw, "bizarre_ordered_fields_4", 13 * 24)

	Scribe.sync_record([Figures, "figure_names_2"], TYPE_ARRAY)
	for i in 16:
		Scribe.put(ScribeFormat.i32, i)
	
	Scribe.sync_record([Scenario, "tutorial_flags_1"], TYPE_ARRAY)
	for i in 26:
		Scribe.put(ScribeFormat.u8, i)
	Scribe.sync_record([Scenario, "tutorial_flags_2"], TYPE_ARRAY)
	for i in 15:
		Scribe.put(ScribeFormat.u8, i)
	
	Scribe.put_grid(ScribeFormat.u8, "unk_grid04", true) # deleted buildings...?
	
	Scribe.sync_record([Scenario], TYPE_OBJECT)
	Scribe.put(ScribeFormat.u8, "mission_play_type")
	
	Scribe.put_grid(ScribeFormat.u8, "moisture", true)
	
	Scribe.sync_record([self], TYPE_OBJECT)
	Scribe.put(ScribeFormat.raw, "bizarre_ordered_fields_2", 10 * 24)
	Scribe.put(ScribeFormat.raw, "bizarre_ordered_fields_3", 18 * 24)
	Scribe.put(ScribeFormat.i32, "unk_junk18")
	
	Scribe.sync_record([Scenario], TYPE_OBJECT)
	Scribe.put(ScribeFormat.i32, "difficulty")
	
	### ======================= POST-FILE VERSION 160 ======================= ###
	
	if debug_schema.file_version >= 160:
		Scribe.sync_record([Military, "campaign_company_rejoin"], TYPE_ARRAY)
		for i in 3:
			Scribe.put(ScribeFormat.u32, i)

		Scribe.sync_record([self], TYPE_OBJECT)
		Scribe.put(ScribeFormat.raw, "bizarre_ordered_fields_5", 27 * 24)
		Scribe.put(ScribeFormat.raw, "bizarre_ordered_fields_6", 27 * 24)
		Scribe.put(ScribeFormat.raw, "bizarre_ordered_fields_7", 15 * 24)
		Scribe.put(ScribeFormat.raw, "bizarre_ordered_fields_8", 56 * 24)
#		Scribe.put(ScribeFormat.raw, "bizarre_ordered_fields_9", 74 * 24)
		Scribe.put(ScribeFormat.raw, "bizarre_ordered_fields_9", 75 * 24) # schema says 75, but sometimes it's 74?

	return Scribe.assert_eof()

#############

var tick = 0
var day = 0
var month = 0
var year = 0
var total_ticks = 0
var total_days = 0

var t = 0
func game_loop(delta):
	t += delta
#	for i in debug_test_spinbox.value:
#		ticks += 1
	pass
func game_tick(delta):
	pass

#############

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(Assets.load_game_assets("Pharaoh"), "completed")
	
	INGAME_ROOT.show()
	MENUS_ROOT.show()
	DEBUG_ROOT.show()
	
#	debug_test_button.connect("pressed", self, "_on_DebugTestBtn_Pressed")
	
#	Assets.load_locales()
#	Assets.load_tilesets()

	
#	close_all_menus()
	
	# TODO:
	# loading:
	
	# bink video: intro
	
#	go_to_menu("Splash")
#	go_to_menu("FamilySelection")
#	go_to_menu("GameSelection", "Banhutep")
#	popup_menu("SavegameSelection", false)
#	go_to_menu("TextureRect2")
#	go_to_menu("Control2")
	
#	Family.JAS_load("D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra/Save/highscore.jas")
#	Family.JAS_save("D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra/Save/highscore2.jas")
	
#	Family.DAT_load("D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra/Save/Banhutep.dat", "Banhutep")
#	Family.DAT_save("D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra/Save/Banhutep2.dat", "Banhutep")


#	var a = YourCustomClass.new()
#	var a = load("res://scripts/mono/YourCustomClass.cs").new()
	
#	yield(get_tree(), "idle_frame")
	Game.load_game("res://../tests/autosave.sav")
#	STATE = States.Ingame
#	close_all_menus()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	game_loop(delta)
