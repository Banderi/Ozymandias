extends Node

const INDUSTRY_RESOURCES = 36

onready var ROOT_NODE = get_tree().root.get_node("Root")
onready var MENUS_ROOT = ROOT_NODE.get_node("Menus")
onready var INGAME_ROOT = ROOT_NODE.get_node("InGame")

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
	Scribe.put("file_version", ScribeFormat.i32)
	Scribe.put("chunks_schema", ScribeFormat.i32)
	var chunks_beginning = Scribe._handle.get_position()
	for i in range(debug_schema.chunks_schema):
		var s = Scribe._handle.get_position()
		Scribe.sync_record([debug_schema, "chunks", i], TYPE_DICTIONARY)
		Scribe.put("compressed", ScribeFormat.u32)
		Scribe.put("memory_offset", ScribeFormat.u8)
		Scribe.put("memory_location", ScribeFormat.u16)
		Scribe.put("unk03", ScribeFormat.u8)
		Scribe.put("fields_size", ScribeFormat.u32)
		Scribe.put("fields_num", ScribeFormat.u32)
		Scribe.put("unk06", ScribeFormat.u16)
		Scribe.put("unk07", ScribeFormat.u16)
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
	Scribe.put("map_index", ScribeFormat.u8)
	Scribe.put("campaign_index", ScribeFormat.u8)
	Scribe.put("prev_progress_pointer", ScribeFormat.i8)
	Scribe.put("mission_progress_pointer", ScribeFormat.i8)
	enscribe_schema()
	
#	Scribe.sync_record([Map.grids], TYPE_DICTIONARY)
	Scribe.put_grid("image", true, ScribeFormat.u32)
	Scribe.put_grid("edge", true, ScribeFormat.i8)
	Scribe.put_grid("building", true, ScribeFormat.i16)
	Scribe.put_grid("terrain", true, ScribeFormat.u32)
	Scribe.put_grid("aqueduct", true, ScribeFormat.u8)
	Scribe.put_grid("figure", true, ScribeFormat.u16)
	Scribe.put_grid("bitfields", true, ScribeFormat.u8)
	Scribe.put_grid("sprite", true, ScribeFormat.u8)
	Scribe.put_grid("random", false, ScribeFormat.u8)
	Scribe.put_grid("desirability", true, ScribeFormat.u8)
	Scribe.put_grid("elevation", true, ScribeFormat.u8)
	Scribe.put_grid("building_dmg", true, ScribeFormat.i16)
	Scribe.put_grid("aqueduct_bak", true, ScribeFormat.u8)
	Scribe.put_grid("sprite_bak", true, ScribeFormat.u8)
	
	Scribe.push_compressed(Figures.MAX_FIGURES * 388) # <---------------------------------- TODO
#	for i in Figures.MAX_FIGURES:
#		Scribe.sync_record([Figures.figures, i], TYPE_DICTIONARY)
#		pass
	Scribe.pop_compressed()
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
	Scribe.put("last_used_formation", ScribeFormat.i32)
	Scribe.put("last_formation_id", ScribeFormat.i32)
	Scribe.put("total_formations", ScribeFormat.i32)
	
	# city data
	Scribe.sync_record([City], TYPE_OBJECT)
	Scribe.push_compressed(37808) # <----------------------------- TODO
	Scribe.pop_compressed()
	Scribe.put("unused_faction_flags1", ScribeFormat.i16)
	Scribe.put("unused_faction_flags2", ScribeFormat.i16)
	Scribe.put("player_name1", ScribeFormat.ascii, 32)
	Scribe.put("player_name2", ScribeFormat.ascii, 32)
	Scribe.put("city_faction", ScribeFormat.i32)
	
	# buildings
	Scribe.sync_record([Buildings], TYPE_OBJECT)
	Scribe.push_compressed(Buildings.MAX_BUILDINGS * 264) # <----------------------------- TODO
	Scribe.pop_compressed()
	
	# camera orientation
	Scribe.sync_record([Map], TYPE_OBJECT)
	Scribe.put("city_orientation", ScribeFormat.i32)
	
	# game time
	Scribe.sync_record([self], TYPE_OBJECT)
	Scribe.put("tick", ScribeFormat.i32)
	Scribe.put("day", ScribeFormat.i32)
	Scribe.put("month", ScribeFormat.i32)
	Scribe.put("year", ScribeFormat.i32)
	Scribe.put("total_days", ScribeFormat.i32)
	
	Scribe.sync_record([Buildings], TYPE_OBJECT)
	Scribe.put("highest_id_ever", ScribeFormat.i32)
	
	Scribe.sync_record([Gods], TYPE_OBJECT)
	Scribe.put("tick_countdown_locusts", ScribeFormat.i32)
	
	# random
	Scribe.sync_record([Random], TYPE_OBJECT)
	Scribe.put("random_iv_1", ScribeFormat.i32)
	Scribe.put("random_iv_2", ScribeFormat.i32)
	
	Scribe.sync_record([Map], TYPE_OBJECT)
	Scribe.put("city_view_camera_x", ScribeFormat.i32)
	Scribe.put("city_view_camera_y", ScribeFormat.i32)
	
	Scribe.sync_record([City], TYPE_OBJECT)
	Scribe.put("city_graph_order", ScribeFormat.i32)
	
	Scribe.sync_record([Gods], TYPE_OBJECT)
	Scribe.put("tick_countdown_hailstorm", ScribeFormat.i32)
	
	# empire
	Scribe.sync_record([Empire], TYPE_OBJECT)
	Scribe.put("empire_map_x", ScribeFormat.i32)
	Scribe.put("empire_map_y", ScribeFormat.i32)
	Scribe.put("empire_selected_object", ScribeFormat.i32)
	Scribe.push_compressed(Empire.MAX_EMPIRE_CITIES * 106) # <----------------------------- TODO
	Scribe.pop_compressed()
	
	# industry buildings
	Scribe.sync_record([City, "industry_buildings_total"], TYPE_ARRAY)
	for i in INDUSTRY_RESOURCES:
		Scribe.put(i, ScribeFormat.i32)
	Scribe.sync_record([City, "industry_buildings_active"], TYPE_ARRAY)
	for i in INDUSTRY_RESOURCES:
		Scribe.put(i, ScribeFormat.i32)
	
	# trade prices
	for i in INDUSTRY_RESOURCES:
		Scribe.sync_record([Empire, "trade_prices", i], TYPE_DICTIONARY)
		Scribe.put("selling", ScribeFormat.i32)
		Scribe.put("buying", ScribeFormat.i32)
	
	# figure names (1)	
	Scribe.sync_record([Figures, "figure_names_1"], TYPE_ARRAY)
	for i in 21:
		Scribe.put(i, ScribeFormat.i32)
	
	# scenario data
	Scribe.sync_record([Scenario, "info"], TYPE_DICTIONARY)
	Scribe.put("TEMP_RAW", ScribeFormat.raw, 1592) # <---------------------------- TODO
	Scribe.put("max_year", ScribeFormat.i32)
	
	# messages
	Scribe.sync_record([Messages], TYPE_OBJECT)
	Scribe.push_compressed(Messages.MAX_MESSAGES * 48) # <----------------------------- TODO
	Scribe.pop_compressed()
	Scribe.put("total_messages_passed", ScribeFormat.i32)
	Scribe.put("total_messages_current", ScribeFormat.i32)
	Scribe.put("last_message_id_highlighted", ScribeFormat.i32)
	Scribe.sync_record([Messages, "census_messages_received"], TYPE_ARRAY)
	for i in 10:
		Scribe.put(i, ScribeFormat.u8)
	Scribe.sync_record([Messages, "message_counts"], TYPE_ARRAY)
	for i in Messages.MESSAGE_CATEGORIES:
		Scribe.put(i, ScribeFormat.i32)
	Scribe.sync_record([Messages, "message_delays"], TYPE_ARRAY)
	for i in Messages.MESSAGE_CATEGORIES:
		Scribe.put(i, ScribeFormat.i32)
	
	# burning buildings
	Scribe.sync_record([Buildings], TYPE_OBJECT)
	Scribe.put("burning_buildings_list_info", ScribeFormat.i32)
	Scribe.put("burning_buildings_size", ScribeFormat.i32)
	
	Scribe.sync_record([Figures], TYPE_OBJECT)
	Scribe.put("figure_sequence", ScribeFormat.i32)
	
	Scribe.sync_record([Scenario], TYPE_OBJECT)
	Scribe.put("starting_kingdom", ScribeFormat.i32)
	Scribe.put("starting_savings", ScribeFormat.i32)
	Scribe.put("starting_rank", ScribeFormat.i32)
	Scribe.push_compressed(101 * 32) # <--------------------------------------------------- TODO
#	Scribe.put("invasion_warnings", ScribeFormat.i32)
	Scribe.pop_compressed()
	Scribe.put("scenario_is_custom", ScribeFormat.i32)
	
	# city sound channels
	Scribe.sync_record([Sounds, "city_sounds"], TYPE_OBJECT)
	for i in Sounds.MAX_CITY_SOUNDS:
		Scribe.put(i, ScribeFormat.raw, 128) # <------------------- TODO
	
	Scribe.sync_record([Buildings], TYPE_OBJECT)
	Scribe.put("highest_id", ScribeFormat.i32)
	
	# traders
	Scribe.sync_record([Figures, "figure_traders"], TYPE_ARRAY)
	for i in Figures.MAX_TRADERS:
		Scribe.put(i, ScribeFormat.raw, 88)
	Scribe.sync_record([Figures], TYPE_OBJECT)
	Scribe.put("next_free_trader_index", ScribeFormat.i32)

	# buildings lists
	Scribe.sync_record([Buildings], TYPE_OBJECT)
	Scribe.push_compressed(500 * 2) # building_list_burning# <--------------------------------------- TODO
	Scribe.pop_compressed()
	Scribe.push_compressed(500 * 2) # building_list_small# <--------------------------------------- TODO
	Scribe.pop_compressed()
	Scribe.push_compressed(Buildings.MAX_BUILDINGS * 2) # building_list_large# <--------------------------------------- TODO
	Scribe.pop_compressed()
	
	Scribe.sync_record([Scenario], TYPE_OBJECT)
	Scribe.put("is_campaign_mission_first", ScribeFormat.i32)
	Scribe.put("is_campaign_mission_first_four", ScribeFormat.i32)
	
	Scribe.sync_record([Figures, "figure_names_3"], TYPE_ARRAY)
	for i in 4:
		Scribe.put(i, ScribeFormat.i32)
	
	Scribe.sync_record([Gods], TYPE_OBJECT)
	Scribe.put("tick_countdown_frogs", ScribeFormat.i32)
	Scribe.put("tick_countdown_pyramid_speedup", ScribeFormat.i32)
	Scribe.put("tick_countdown_blood1", ScribeFormat.i32)
	Scribe.put("unkn_06", ScribeFormat.raw, 5*4) # ????
	
	Scribe.sync_record([Buildings, "storage_yards_settings"], TYPE_ARRAY)
	for i in Buildings.MAX_STORAGE_YARDS:
		Scribe.put(i, ScribeFormat.raw, 196) # <--------------------------------------- TODO
	
	Scribe.sync_record([Empire], TYPE_OBJECT)
	Scribe.push_compressed(Empire.MAX_TRADE_ROUTES * INDUSTRY_RESOURCES * 4) # trade_routes_limits <------------------ TODO
	Scribe.pop_compressed()
	Scribe.push_compressed(Empire.MAX_TRADE_ROUTES * INDUSTRY_RESOURCES * 4) # trade_routes_traded <------------------ TODO
	Scribe.pop_compressed()
	
	Scribe.sync_record([Military], TYPE_OBJECT)
	Scribe.put("working_towers", ScribeFormat.i32)
	
	Scribe.sync_record([Buildings], TYPE_OBJECT)
	Scribe.put("creation_highest_id", ScribeFormat.i32)
	
	Scribe.sync_record([Routing], TYPE_OBJECT)
	Scribe.put("routing_debug", ScribeFormat.i32)

	## ============== unknown / debug stuff ============== ##
	Scribe.sync_record([self], TYPE_OBJECT)
	Scribe.put("unkn_debug_00", ScribeFormat.i32)
	Scribe.put("unkn_debug_01", ScribeFormat.i32)
	Scribe.put("unkn_debug_02", ScribeFormat.i32)
	Scribe.put("unkn_debug_03_a", ScribeFormat.i32)
	Scribe.put("unkn_debug_03_b", ScribeFormat.i32)
	Scribe.put("unkn_debug_04_a", ScribeFormat.i32)
	Scribe.put("unkn_debug_04_b", ScribeFormat.i32)
	
	Scribe.sync_record([Military], TYPE_OBJECT)
	Scribe.put("invasions_creation_sequence", ScribeFormat.i16)
	
	Scribe.sync_record([Buildings], TYPE_OBJECT)
	Scribe.put("corrupt_house_coords_repaired", ScribeFormat.u32)
	Scribe.put("corrupt_house_coords_deleted", ScribeFormat.u32)
	
	Scribe.sync_record([Scenario], TYPE_OBJECT)
	Scribe.put("scenario_map_name", ScribeFormat.ascii, 65)
	
	for i in Map.MAX_BOOKMARKS:
		Scribe.sync_record([Map, "bookmarks", i], TYPE_DICTIONARY)
		Scribe.put("x", ScribeFormat.i8)
		Scribe.put("y", ScribeFormat.i8)
	
	Scribe.sync_record([Gods], TYPE_OBJECT)
	Scribe.put("tick_countdown_blood2", ScribeFormat.i32)

	# ============== ????
	Scribe.sync_record([self], TYPE_OBJECT)
	Scribe.put("unk_05", ScribeFormat.i32)
	Scribe.put("unk_06", ScribeFormat.i32)
	
	# ============== ????
	Scribe.sync_record([Scenario, "unk_fields"], TYPE_ARRAY)
	for i in 99:
		Scribe.put(i, ScribeFormat.i32)

	Scribe.put_grid("fertility", false, ScribeFormat.u8)
	
	for i in Scenario.MAX_EVENTS:
		Scribe.sync_record([Scenario, "events", i], TYPE_DICTIONARY)
		Scribe.put("TEMP", ScribeFormat.raw, 124) # <---------------------------- TODO
	Scribe.sync_record([Scenario, "events_extra"], TYPE_DICTIONARY)
	Scribe.put("unk00", ScribeFormat.i32)
	Scribe.put("unk01", ScribeFormat.i32)
	Scribe.put("unk02", ScribeFormat.i32)
	Scribe.put("unk03", ScribeFormat.i32)
	Scribe.put("unk04", ScribeFormat.i32)
	Scribe.put("unk05", ScribeFormat.i32)
	Scribe.put("unk06", ScribeFormat.i32)
	
	# ferries
	for i in Figures.MAX_FERRIES:
		Scribe.sync_record([Figures, "ferry_queues", i], TYPE_ARRAY)
		for j in Figures.MAX_FIGURES_WAITING_PER_FERRY:
			Scribe.put(j, ScribeFormat.i32)
	for i in Figures.MAX_FERRIES:
		Scribe.sync_record([Figures, "ferry_transiting", i], TYPE_ARRAY)
		for j in Figures.MAX_FIGURES_PER_FERRY:
			Scribe.put(j, ScribeFormat.i32)
	
	# ============== ????
	Scribe.sync_record([self], TYPE_OBJECT)
	Scribe.put("unused_figure_sequences", ScribeFormat.raw, 4 * 4)
	Scribe.put("unused_10_x_820", ScribeFormat.raw, 10 * 820)
	
	Scribe.sync_record([Empire], TYPE_OBJECT)
	Scribe.push_compressed(40 * 32) # unused multiple-empires leftover stuff from C3
	Scribe.pop_compressed()
	Scribe.push_compressed(Empire.MAX_MAP_OBJECTS * 98) # empire_map_objects <-------------------------------- TODO
	Scribe.pop_compressed()
	Scribe.push_compressed(Empire.MAX_EMPIRE_ROUTES * 324) # empire_map_routes <-------------------------------- TODO
	Scribe.pop_compressed()
	
	Scribe.put_grid("vegetation_growth", false, ScribeFormat.u8)
	
	# ============== ????
	Scribe.sync_record([self], TYPE_OBJECT)
	Scribe.put("unk_junk14_a_1", ScribeFormat.i32)
	Scribe.put("unk_junk14_a_2", ScribeFormat.i32)
	Scribe.put("unk_junk14_a_3", ScribeFormat.i32)
	Scribe.put("unk_junk14_a_4", ScribeFormat.i32)
	Scribe.put("unk_junk14_b_1", ScribeFormat.u8)
	Scribe.put("unk_junk14_b_2", ScribeFormat.u8)
	Scribe.put("unk_junk14_b_3", ScribeFormat.u8)
	Scribe.put("unk_junk14_b_4", ScribeFormat.u8)
	Scribe.put("bizarre_ordered_fields_1", ScribeFormat.raw, 22 * 24)
	
	# floodplain data
	Scribe.push_compressed(36) # floodplain_settings <-------------------------------- TODO
	Scribe.pop_compressed()
	
	Scribe.put_grid("unk_grid03", true, ScribeFormat.i32) # routing cache...?
	
	
	Scribe.sync_record([self], TYPE_OBJECT)
	Scribe.put("bizarre_ordered_fields_4", ScribeFormat.raw, 13 * 24)

	Scribe.sync_record([Figures, "figure_names_2"], TYPE_ARRAY)
	for i in 16:
		Scribe.put(i, ScribeFormat.i32)
	
	Scribe.sync_record([Scenario, "tutorial_flags_1"], TYPE_ARRAY)
	for i in 26:
		Scribe.put(i, ScribeFormat.u8)
	Scribe.sync_record([Scenario, "tutorial_flags_2"], TYPE_ARRAY)
	for i in 15:
		Scribe.put(i, ScribeFormat.u8)
	
	Scribe.put_grid("unk_grid04", true, ScribeFormat.u8) # deleted buildings...?
	
	Scribe.sync_record([Scenario], TYPE_OBJECT)
	Scribe.put("mission_play_type", ScribeFormat.u8)
	
	Scribe.put_grid("moisture", true, ScribeFormat.u8)
	
	Scribe.sync_record([self], TYPE_OBJECT)
	Scribe.put("bizarre_ordered_fields_2", ScribeFormat.raw, 10 * 24)
	Scribe.put("bizarre_ordered_fields_3", ScribeFormat.raw, 18 * 24)
	Scribe.put("unk_junk18", ScribeFormat.i32)
	
	Scribe.sync_record([Scenario], TYPE_OBJECT)
	Scribe.put("difficulty", ScribeFormat.i32)
	
	### ======================= POST-FILE VERSION 160 ======================= ###
	
	if debug_schema.file_version >= 160:
		Scribe.sync_record([Military, "campaign_company_rejoin"], TYPE_ARRAY)
		for i in 3:
			Scribe.put(i, ScribeFormat.u32)

		Scribe.sync_record([self], TYPE_OBJECT)
		Scribe.put("bizarre_ordered_fields_5", ScribeFormat.raw, 27 * 24)
		Scribe.put("bizarre_ordered_fields_6", ScribeFormat.raw, 27 * 24)
		Scribe.put("bizarre_ordered_fields_7", ScribeFormat.raw, 15 * 24)
		Scribe.put("bizarre_ordered_fields_8", ScribeFormat.raw, 56 * 24)
#		Scribe.put("bizarre_ordered_fields_9", ScribeFormat.raw, 74 * 24)
		Scribe.put("bizarre_ordered_fields_9", ScribeFormat.raw, 75 * 24) # schema says 75, but sometimes it's 74?

	return Scribe.assert_eof()

#############


var tick = 0
var day = 0
var month = 0
var year = 0
var total_ticks = 0
var total_days = 0
func game_loop(delta):
#	for i in debug_test_spinbox.value:
#		ticks += 1
	pass
func game_tick(delta):
	pass

#############

# Called when the node enters the scene tree for the first time.
func _ready():
	debug_test_button.connect("pressed", self, "_on_DebugTestBtn_Pressed")

	Assets.load_locales()
	Assets.load_tilesets()

	
#	close_all_menus()
	
	# TODO:
	# loading:
	
	# bink video: intro
	
#	go_to_menu("Splash")
#	go_to_menu("FamilySelection")
	go_to_menu("GameSelection", "Banhutep")
#	popup_menu("SavegameSelection", false)
#	go_to_menu("TextureRect2")
#	go_to_menu("Control2")
	
#	Family.JAS_load("D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra/Save/highscore.jas")
#	Family.JAS_save("D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra/Save/highscore2.jas")
	
#	Family.DAT_load("D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra/Save/Banhutep.dat", "Banhutep")
#	Family.DAT_save("D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra/Save/Banhutep2.dat", "Banhutep")


#	var a = YourCustomClass.new()
#	var a = load("res://scripts/mono/YourCustomClass.cs").new()
	
	yield(get_tree(),"idle_frame")
	Game.load_game("res://../tests/autosave.sav")
#	STATE = States.Ingame
#	close_all_menus()


onready var DEBUG_ROOT = ROOT_NODE.get_node("Debug")
onready var debug_label = DEBUG_ROOT.get_node("DEBUG_LABEL")
onready var debug_fps_label = DEBUG_ROOT.get_node("DEBUG_FPS")
onready var debug_test_label = DEBUG_ROOT.get_node("DEBUG_LABEL2")
onready var debug_test_spinbox = debug_test_label.get_node("SpinBox")
onready var debug_test_button = debug_test_label.get_node("Button")

var last_fps = 60
var test_adj = 1
func _on_DebugTestBtn_Pressed():
	pass
func tick_maxfps_test(delta):
	if (1.0 / delta) < 59.8:
		test_adj = min(test_adj - 10, 0)
	else:
		test_adj = max(test_adj + 1, 0)
	debug_test_spinbox.value += test_adj

# Called every frame. 'delta' is the elapsed time since the previous frame.
var t = 0
func _process(delta):
	t += delta
#	if t > 1:
#		TranslationServer.set_locale("en")
#	if t > 2:
#		t = 0
#		TranslationServer.set_locale("it")

	game_loop(delta)

	# debug prints
	var debug_text = "[color=#888888]Ozymandias Godot3.6 v0.2[/color]\n"
	debug_text += "[color=#888888]game_state:[/color]       %s\n" % [Log.get_enum_string(States, STATE)]
	debug_text += "[color=#888888]last_menu:[/color]        %s\n" % [debug_last_menu]
	debug_text += "[color=#888888]current_family:[/color]   %s\n" % [Family.current_family]
	debug_text += "[color=#888888]families:[/color]         %s\n" % [Family.data.size()]
	#
	debug_text += "[color=#888888]camera:[/color]              %s\n" % [INGAME_ROOT.CAMERA.position]
	debug_text += "[color=#888888]zoom:[/color]                %s\n" % [INGAME_ROOT.camera_zoom_target]
	debug_text += "[color=#888888]curr_click_mouse:[/color]    %s\n" % [INGAME_ROOT.current_click_game_coords]
	debug_text += "[color=#888888]last_click_mouse:[/color]    %s\n" % [INGAME_ROOT.last_click_game_coords]
	debug_text += "[color=#888888]last_click_camera:[/color]   %s\n" % [INGAME_ROOT.camera_previous_game_coords]
	
	if debug_label.bbcode_text != debug_text:
		debug_label.bbcode_text = debug_text
	
	last_fps = Engine.get_frames_per_second()
	debug_fps_label.text = str(last_fps, " FPS")
	
	if debug_test_label.visible:
		debug_test_label.text = "%s (%s)\n%s" % [delta, 1.0 / delta, total_ticks]
		tick_maxfps_test(delta)
