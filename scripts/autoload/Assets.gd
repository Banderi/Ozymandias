tool
extends Node

# generics
func file_seek(file: File, bytes: PoolByteArray, begin: int = 0): # this REQUIRES a valid file handle 
	var filesize = file.get_len()
	var search_size = bytes.size()
	file.seek(begin)
	while !file.eof_reached():
		var _offset = file.get_position()
		var available_left = filesize - _offset
		if available_left < search_size:
			return -1
		var r = file.get_buffer(bytes.size())
		if r == bytes:
			return _offset
		file.seek(_offset + 1) # sadly..... we must do EVERY byte.
	return -1

## ======================== GAMESETS / DATA PATHS ========================  ##

# game set
var GAME_SET = null
func set_gameset(game): # TODO - for the future
	GAME_SET = game
	GAME_FILES = {} # clear cached paths
	if !(GAME_SET in SG_CACHE):
		SG_CACHE[GAME_SET] = {}
#	if !(GAME_SET in SG_TEXTURES_LOOKUP):
#		SG_TEXTURES_LOOKUP[GAME_SET] = {}
	
	GridsMono.GRID_SIZE = Map.get_grid_size()
	Figures.init_figure_stack()
	Buildings.init_building_stack()

# user / res & game data paths
onready var INSTALL_PATH_SELECT_DIALOG = get_tree().root.get_node("Root/Menus/FileDialog") as FileDialog
const USER_ASSETS_PATH = "user://assets_cache"
var SAVES_PATH = null
var GAME_FILES = {} # this is the actual cache list of game files paths, when (if) found
func find_and_record_game_file(file_name: String, subdir: String = ""):
	var path = IO.find_file_recursive(str(Settings.INSTALL_PATH, subdir), file_name, true)
	if path == null:
		return Log.error(self, ERR_FILE_NOT_FOUND, "could not find %s within game folders" % [file_name])
	GAME_FILES[file_name] = path
	return path
func get_game_file_path(file_name: String): # this is SYNCHRONOUS and does NOT ask to select a new folder.
	var path = GAME_FILES.get(file_name, null)
	if path == null:
		return find_and_record_game_file(file_name)
	return path
func ASYNC_get_game_file_path(file_name: String): # this is ASYNCHRONOUS and WILL ask to select a new folder.
	var path = GAME_FILES.get(file_name, null)
	while path == null:
		path = IO.find_file_recursive(Settings.INSTALL_PATH, file_name)
		if path == null:
			yield(ASYNC_set_game_install_paths(false, "Can not find %s!" % [file_name]), "completed")
			
		yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
func ASYNC_set_game_install_paths(force_user_select: bool, title_text: String, dialog_text: String = "Please select the folder containing %s game data.\n" % [GAME_SET]):
	if Settings.INSTALL_PATH == null || force_user_select:
		yield(get_tree(), "idle_frame") # required for tree nodes (e.g. FileDialog) to set up before usage.
		SAVES_PATH = null
		Settings.update("INSTALL_PATH", null)
		var satisfied = false
		var path = null
		while !satisfied:
			INSTALL_PATH_SELECT_DIALOG.dialog_text = dialog_text
			INSTALL_PATH_SELECT_DIALOG.window_title = title_text
			INSTALL_PATH_SELECT_DIALOG.popup_centered()
			path = yield(INSTALL_PATH_SELECT_DIALOG, "chosen")
			
			satisfied = path != null
#			if !IO.file_exists(str(path, "/Pharaoh_Text.eng")): satisfied = false
#			if !IO.file_exists(str(path, "/Pharaoh_MM.eng")): satisfied = false
#			if !IO.file_exists(str(path, "/Data/Pharaoh_Terrain.sg3")): satisfied = false
			
			if !satisfied:
				yield(Engine.get_main_loop(), "idle_frame") # relinquish async to allow ConfirmationDialogExt to reset
		Settings.update("INSTALL_PATH", path)
	else:
		yield(get_tree(), "idle_frame")
	
	# enumerate game files and record their paths
	SAVES_PATH = Settings.INSTALL_PATH + "/Save"

func get_game_cache_path():
	return USER_ASSETS_PATH + "/" + GAME_SET

## ============================== GAME TEXT ==============================  ##

# game text and locales
func editor_debug_translate_labels(node): # in-editor text localization refresh for labels & buttons
	if Engine.is_editor_hint():
		var l_n = node.get_node_or_null("TL_LABEL_DEBUG")
		if l_n == null:
			l_n = Label.new()
			l_n.name = "TL_LABEL_DEBUG"
			l_n.text = ""
			l_n.set("custom_colors/font_color_shadow", Color("5f000000"))
			l_n.set("custom_constants/shadow_as_outline", 1)
			node.add_child(l_n)
			l_n.set_meta("l_n", "")
		if node.localized_key != "":
			if l_n.get_meta("l_n") != node.localized_key:
				l_n.set_meta("l_n", node.localized_key)
				var text_en = load("res://assets/locales/Pharaoh_Text.en.translation")
				l_n.text = node.localized_key
				var tr_text = text_en.get_message(node.localized_key)
				if tr_text != node.localized_key:
					node.text = text_en.get_message(node.localized_key)
					print("updated: %s (%s)" % [node.text, node.localized_key])
func load_text(path: String, locale: String):
	var file = IO.open(path, File.READ) as FileEx
	if file == null:
		return null

	# header (28 bytes)
	var header_title = file.get_buffer(16).get_string_from_ascii()
	var header_num_groups = file.get_32()
	var header_num_text = file.get_32()
	var header_unk02 = file.get_32()
	
	# offsets (1000 entries of 4 bytes each)
	var lang_groups = {} # using dict here to store the entries by their FORMAL index in the file, JUST in case something breaks.
	for i in range(header_num_groups):
		var offset = file.get_32()
		var in_use = file.get_32()
		if in_use:
			lang_groups[i] = offset
		else:
			lang_groups[i] = null
	
	# actual data
	var tr = Translation.new()
	tr.set_locale(locale)
	var text_data_start = 8028
	file.seek(text_data_start)
	for i in lang_groups:
		if lang_groups[i] == null: # skip unused fields (first one in Pharaoh_Text.eng has in_use == 0 because the devs wanted to start from "1" 
			continue
		
		var group_file_offset = text_data_start + lang_groups[i]
		var group_file_offset_next = text_data_start + lang_groups[i + 1] if i < (lang_groups.size() - 1) else -1
		
		file.seek(group_file_offset)
		var line_i = 0
		
		while file.get_position() < file.get_len() - 1 && (group_file_offset_next == -1 || file.get_position() < group_file_offset_next):
			var line_text = file.get_null_terminated_string()
			var line_key = "TEXT_%d_%d" % [i, line_i]
			tr.add_message(line_key, line_text)
			line_i += 1
	var total_text_entries = tr.get_message_count()
	assert(total_text_entries == header_num_text)
	
	
	file.close()
	return tr
func load_mm(path: String, locale: String): # TODO
	var file = IO.open(path, File.READ) as FileEx
	if file == null:
		return null
#	buffer_skip(buf, 24); // header
#    for (int i = 0; i < MAX_MESSAGE_ENTRIES; i++) {
#        lang_message *m = &data.message_entries[i];
#        m->type = buffer_read_i16(buf);
#        m->message_type = buffer_read_i16(buf);
#        buffer_skip(buf, 2);
#        m->x = buffer_read_i16(buf);
#        m->y = buffer_read_i16(buf);
#        m->width_blocks = buffer_read_i16(buf);
#        m->height_blocks = buffer_read_i16(buf);
#        m->image.id = buffer_read_i16(buf);
#        m->image.x = buffer_read_i16(buf);
#        m->image.y = buffer_read_i16(buf);
#        buffer_skip(buf, 6); // unused image2 id, x, y
#        m->title.x = buffer_read_i16(buf);
#        m->title.y = buffer_read_i16(buf);
#        m->subtitle.x = buffer_read_i16(buf);
#        m->subtitle.y = buffer_read_i16(buf);
#        buffer_skip(buf, 4);
#        m->video.x = buffer_read_i16(buf);
#        m->video.y = buffer_read_i16(buf);
#        buffer_skip(buf, 14);
#        m->urgent = buffer_read_i32(buf);
#
#        m->video.text = get_message_text(buffer_read_i32(buf));
#        buffer_skip(buf, 4);
#        m->title.text = get_message_text(buffer_read_i32(buf));
#        m->subtitle.text = get_message_text(buffer_read_i32(buf));
#        m->content.text = get_message_text(buffer_read_i32(buf));
#    }
#    buffer_read_raw(buf, &data.message_data, MAX_MESSAGE_DATA);
	file.close()

## =============================== GRAPHICS ==============================  ##

func load_png(path: String, flags: int):
	var image = Image.new()
	var r = image.load(path)
	if r != OK:
		return null
	var texture = ImageTexture.new()
	texture.create_from_image(image, flags)
	return texture


var SG_CACHE = {}
func get_sgx_path(pak_name: String):
	var filename_sgx = pak_name + SG_EXTENSION[GAME_SET] # e.g. ".sg3" for Pharaoh
	return get_game_file_path(filename_sgx)
func extract_sgx(pak_name: String):
	var path = get_sgx_path(pak_name) # full path to .sgx file
	if path == null:
		return false
	if !SG.open(path): # open & parse pak
		return false
	if !SG.extract_all((true if SG_PAKS[GAME_SET][pak_name][2] >= 201 else false)):
		return false
	SG_CACHE[GAME_SET][pak_name] = SG.get_data() # store in memory (this should NEVER return null or fail)
	IO.write(str(get_game_cache_path(), "/Data/" , pak_name, ".CACHED"), SG_CACHE[GAME_SET][pak_name]) # try to save to disk, ignoring errors
	return true
func get_SG_data(pak_name: String): # return (ref) cached SG data
	
	#  OPTION 1: check the data in memory
	if pak_name in SG_CACHE[GAME_SET]:
		return SG_CACHE[GAME_SET][pak_name]
	
	#  OPTION 2: check cache saved to disk
	var path_cached = str(get_game_cache_path(), "/Data/" , pak_name, ".CACHED")
	var r = IO.read(path_cached, false)
	if r != null:
		SG_CACHE[GAME_SET][pak_name] = r
		return SG_CACHE[GAME_SET][pak_name]
	
	#  OPTION 3: extract from game files
	if !extract_sgx(pak_name):
		return null
	return SG_CACHE[GAME_SET][pak_name]

func _sg_get_img_record(pak_name: String, img_idx: int):
	var sginfo = get_SG_data(pak_name)
	if sginfo == null:
		return null
	if img_idx >= sginfo.img.size():
		return Log.error("_sg_get_img_record", ERR_DOES_NOT_EXIST, "pak '%s' does not contain any image at index %d" % [pak_name, img_idx])
	return sginfo.img[img_idx] # first one is a dummy BUT it is present, so the array MATCHES the naive alignment!
func _sg_get_bmp_record(pak_name: String, bmp_idx: int):
	var sginfo = get_SG_data(pak_name)
	if sginfo == null:
		return null
	if bmp_idx >= sginfo.bmp.size():
		return Log.error("_sg_get_img_record", ERR_DOES_NOT_EXIST, "pak '%s' does not contain any bitmap at index %d" % [pak_name, bmp_idx])
	return sginfo.bmp[bmp_idx]
func _sg_get_tag_record(pak_name: String, tag_idx: int):
	var sginfo = get_SG_data(pak_name)
	if sginfo == null:
		return null
	if tag_idx >= sginfo.tag.size() || sginfo.tag[tag_idx] == null:
		return Log.error("_sg_get_img_record", ERR_DOES_NOT_EXIST, "pak '%s' does not contain any valid tag (group) at index %d" % [pak_name, tag_idx])
	return sginfo.tag[tag_idx]

func get_SG_texture(pak_name: String, img_idx: int, seek_cache_only: bool) -> Texture: # this uses the pak's own record indices -- it COUNTS SYSTEM.BMP AS WELL AS THE DUMMY RECORD.
	
	#  OPTION 1: read cached raw texture streams -- around ~380 ms
	var path_cached = str(get_game_cache_path(), "/Data/", pak_name, "/", img_idx, ".texture")
	var texture = IO.read(path_cached, false, true)
	if texture != null || seek_cache_only:
		return texture
	
	#  OPTION 2: extract from SG paks -- ?? ms
	var sginfo = get_SG_data(pak_name)
#	texture = extract_single_sg_texture(pak_name, img_idx)
	texture = sginfo.textures.get(img_idx, null)
	if texture != null:
		IO.write(path_cached, texture, true) # save to cache
		return texture
	
	# return results
	if texture == null:
		Log.error("get_SG_texture", ERR_FILE_NOT_FOUND, "could not load game texture %d of pak %s" % [img_idx, pak_name])
	return texture
func get_tagged_sg_texture_idx(pak_name: String, tag_idx: int, spr_offset: int):
	var tag = _sg_get_tag_record(pak_name, tag_idx)
	if tag == null:
		return null
	return tag.img + spr_offset
func get_tagged_sg_texture(pak_name: String, tag_idx: int, spr_offset: int, seek_cache_only: bool) -> Texture:
	var img_idx = get_tagged_sg_texture_idx(pak_name, tag_idx, spr_offset)
	if img_idx == null:
		return null
	return get_SG_texture(pak_name, img_idx, seek_cache_only)

# gameset-specific SG paks, image id lookups and texture fetch
const SG_EXTENSION = {
	"Pharaoh": ".sg3" }
const SG_PAKS = { # These are the ranges of game paks and how they're laid out in the global image lookup.
				  #                   start id        final id      start       end
	"Pharaoh": {  #                   (global)        (global)      (pak)      (pak)
		"Pharaoh_Unloaded": 	[		    1,            682,         1,       682],
		"SprMain": 				[		  683,          11007,         1,     10325],
		
		"Assyrian":				[		11008,          11906,         1,       899],
		"Enemy_1":				[		11008,          11736,         1,       729],
		"Canaanite":			[		11008,          11866,         1,       859],
		"Hittite":				[		11008,          11874,         1,       867],
		"Hyksos":				[		11008,          11906,         1,       899],
		"Kushite":				[		11008,          11866,         1,       859],
		"Libian":				[		11008,          11866,         1,       859],
		"Mitani":				[		11008,          11906,         1,       899],
		"Nubian":				[		11008,          11834,         1,       827],
		"Persian":				[		11008,          11874,         1,       867],
		"Phoenician":			[		11008,          11842,         1,       835],
		"Roman":				[		11008,          11882,         1,       875],
		"SeaPeople":			[		11008,          11841,         1,       834],
		
		"Pharaoh_General":		[		11907,          14452,       201,      2746],
		"Pharaoh_Terrain":		[		14453,          15767,       201,      1515],
		
		"sphinx1a":				[		15768,          15769,       201,       202],
		"sphinx1b":				[		15770,          15771,       201,       202],
		"sphinx1c":				[		15772,          15773,       201,       202],
		"sphinx1d":				[		15774,          15775,       201,       202],
		
		"obelisk5x5a":			[		15768,          15768,       201,       201],
		"obelisk3x3a":			[		15770,          15770,       201,       201],
		"obelisk_extra":		[		15776,          15791,       201,       216],
		
		"Temple_nile":			[		15792,          15829,       201,       238],
		"Temple_ra":			[		15792,          15829,       201,       238],
		"Temple_ptah":			[		15792,          15829,       201,       238],
		"Temple_seth":			[		15792,          15829,       201,       238],
		"Temple_bast":			[		15792,          15829,       201,       238],
		
		"Empire":				[		15830,          15830,       201,       201],
		
		"SprAmbient":			[		15831,          18764,         1,      2934],
		"Pharaoh_Fonts":		[		18765,          20104,       201,      1540],
		"Egyptian":				[		20105,          20883,         1,       779],
		"SprMain2":				[		20884,          23235,         1,      2352],
		"Expansion":			[		23236,          23935,       201,       900],
		
		"Pyramid":				[		23936,          24163,       201,       428],
		"Mastaba":				[		23936,          24935,       201,       900],
		"PyramidDummy":			[		23936,          24163,       201,       428],
		# ?? (dummy yellow squares until end)
		# canonical end = 25139
		
		# ---------------- non-canon order override!! ---------------- #
		
#		"Pyramid":				[		30000,          30227,       201,       428],

	} }
#var SG_TEXTURES_LOOKUP = {}
#func extract_sg_pak(pak_name, force_reextract: bool = false):
#	var _t = Stopwatch.start()
##	var pak_name = pak_range_info[0]
#	var pak_range_info = SG_PAKS[pak_name]
#	var start_img_id = pak_range_info[0]
#	var end_img_id = pak_range_info[1]
#	var skip_initial = pak_range_info[2]
#	var total_img_records = pak_range_info[3]
#
#	var r = parse_full_sgx(pak_name, true)
#	if r != total_img_records:
#		return false
#	if r + start_img_id - skip_initial != end_img_id:
#		var shouldvebeen = r + start_img_id - skip_initial
#		return false
##	var pak_name = IO.strip_extension(pak_name)
#
#	var textures = extract_full_sgx(pak_name + ".555", (true if skip_initial >= 201 else false), force_reextract)
#	if textures == null:
#		return false
#	else:
#		SG_TEXTURES_LOOKUP[GAME_SET].merge(textures)
#	Stopwatch.stop("extract_sg_pak", _t, "extracted SG pak '%s'" % [pak_name])
func extract_sg_paks(): # parse sgx records AND extract images to cache, if missing
	var _t = Stopwatch.start()
	for pak_name in SG_PAKS[GAME_SET].size():
		if !extract_sgx(pak_name):
			return false
	Stopwatch.stop("extract_sg_paks", _t, "SG paks loaded for game '%s'" % [GAME_SET])
	return true
#func get_gameset_sg_texture(img_id: int, seek_cache_only: bool): # this takes into account ONLY THE CANON ORDER, and thus ONLY THE FIRST OVERLAPPING PAK FOUND
#
##	if GAME_SET in SG_TEXTURES_LOOKUP && img_id in SG_TEXTURES_LOOKUP[GAME_SET]:
##		return SG_TEXTURES_LOOKUP[GAME_SET][img_id]
#	if GAME_SET in SG_CACHE && img_id in SG_CACHE[GAME_SET].textures:
#		return SG_CACHE[GAME_SET].textures[img_id]
#
#	elif !seek_cache_only && GAME_SET in SG_PAKS:
#		for i in SG_PAKS[GAME_SET].size():
#			var pak_range_info = SG_PAKS[GAME_SET][i]
#			var pak_name = pak_range_info[0]
#			var start_img_id = pak_range_info[1]
#			var end_img_id = pak_range_info[2]
#			var skip_initial = pak_range_info[3]
#			if img_id >= start_img_id && img_id <= end_img_id:
#				return get_SG_texture(pak_name, img_id - start_img_id + skip_initial, false)
#		Log.error(self, ERR_DOES_NOT_EXIST, "image id '%s' could not be resolved" % [img_id])
#	else:
#		Log.error(self, ERR_METHOD_NOT_FOUND, "game set '%s' is not implemented" % [GAME_SET])
#	return null

# animated sprites: TODO

func get_animated_sprite_texture(pak_name: String, tag_idx: int, seek_cache_only: bool):
	var img_idx = get_tagged_sg_texture_idx(pak_name, 5, 0)
	if img_idx == null:
		return null
	var img = _sg_get_img_record(pak_name, img_idx)
#	var bmp = _sg_get_bmp_record(pak_name, tag_idx)
	pass

# tiles and tileset ops
const TILESETS = {
	"Pharaoh": {
		# these are the STATIC paks that are common to all combinations of enemy, theater, monument era etc.
		# --- so it's "shared" as in shared to all of the above, NOT as in those that use SHARED ID SPACES. 
		"shared": ["Pharaoh_General", "Pharaoh_Terrain", "Expansion"],
		"unloaded": [
			"Pyramid"
		]
	}
}
const TILE_WIDTH_PIXELS = 60
const TILE_HEIGHT_PIXELS = 30
const HALF_TILE_WIDTH_PIXELS = 30
const HALF_TILE_HEIGHT_PIXELS = 15
var SHARED_TILESET = null
var FULL_TILESET = null
func tileset_add_tile_from_texture(tileset: TileSet, texture: Texture, id: int): # constructs tile from texture and add to tileset
#	if id == 850 + 14252:														 # for some reason, this shows [Null] in editor
#		texture = get_SG_texture("Pharaoh_Terrain.sg3", 850)					 # upon applying certain textures. e.g.:
	var tile_size = (texture.get_size().x + 2) / TILE_WIDTH_PIXELS				 # - Pharaoh_Terrain @ 850 (SPR_B_DOCK_E)
	tileset.create_tile(id)
	tileset.tile_set_texture(id, texture)
	tileset.tile_set_texture_offset(id, Vector2(0, (15 * (tile_size + 1)) - texture.get_size().y))
func add_pak_sprites_into_tileset(tileset: TileSet, pak_name: String, canon_sequence: bool) -> bool: # DO NOT USE this on a tileset IN USE in a TileMap! DETACH it first!!
	var _t = Stopwatch.start()
	if tileset == null:
		Log.error("add_pak_sprites_into_tileset", ERR_INVALID_PARAMETER, "tileset parameter was passed null")
		return false
	
	# find pak info in gameset records
	var pak_range_info = SG_PAKS[GAME_SET].get(pak_name, null)
#	var pak_range_info = null
#	if canon_sequence:
#		for pak_name in SG_PAKS[GAME_SET]:
#			pak_range_info = SG_PAKS[GAME_SET][pak_name]
#			if pak_range_info[1] >= 30000:
#				break
#			if pak_name != pak_range_info[0]:
#				pak_range_info = null
#			else:
#				break
#		if pak_range_info == null:
#			Log.error("add_pak_sprites_into_tileset", ERR_DOES_NOT_EXIST, "file '%s' not found in gameset pak records" % [pak_name])
#			return false
#	else:
#		var paks_in_order = SG_PAKS[GAME_SET].keys()
#		for i in range(paks_in_order.size()-1, -1, -1):
#			var pak_name = paks_in_order[i]
#			pak_range_info = SG_PAKS[GAME_SET][pak_name]
#			if pak_range_info[1] < 30000:
#				break
#			if pak_name != pak_range_info[0]:
#				pak_range_info = null
#			else:
#				break
#		if pak_range_info == null:
#			Log.error("add_pak_sprites_into_tileset", ERR_DOES_NOT_EXIST, "file '%s' not found in gameset pak records" % [pak_name])
#			return false
	if pak_range_info == null:
		Log.error("add_pak_sprites_into_tileset", ERR_DOES_NOT_EXIST, "file '%s' not found in gameset pak records" % [pak_name])
		return false
	
	var global_start_img_id = pak_range_info[0]
	var global_end_img_id = pak_range_info[1]
	var skip_initial = pak_range_info[2]
		
	
	# get .sgx header data
#	var pak_name = IO.strip_extension(pak_name) # naked SG pak name
#	if !(pak_name in SG_CACHE) || !("header" in SG_CACHE[GAME_SET][pak_name]): # check if data was already parsed
#		if !parse_full_sgx(pak_name):
#			return false
#	var pak_header = sginfo.header
	
	var sginfo = get_SG_data(pak_name)
	if sginfo == null:
		return false
	
	# load images within the boundaries of the global ids of this pak
	var replaced = 0
	var skipped = 0
	var last_img_id = null
	for i in range(skip_initial, sginfo.header.img_records + 1): # img_records does NOT include the dummy image at #0
		var texture = get_SG_texture(pak_name, i, true)
		if texture == null:
			skipped += 1
			continue
		last_img_id = global_start_img_id + (i - skip_initial)
		
		# remove tile if already present
		if tileset.get_tiles_ids().has(last_img_id):
			replaced += 1
			tileset.remove_tile(last_img_id)
		tileset_add_tile_from_texture(tileset, texture, last_img_id)
	
	if last_img_id != global_end_img_id:
		Log.error("add_pak_sprites_into_tileset", ERR_BUG, "pak '%s' image ids do not add up as expected (%d != %d)" % [pak_name, last_img_id, global_end_img_id])
		return false
	Log.generic("add_pak_sprites_into_tileset", "'%s' (%d ms) -- tiles %d --> %d, %d replaced, %d skipped" % [
		pak_name,
		Stopwatch.query(_t, Stopwatch.Milliseconds),
		global_start_img_id,
		last_img_id,
		replaced,
		skipped
	])
	return true

## ============================== GAME INIT ==============================  ##

func load_locales() -> bool: # TODO: MM, check user settings, add different locales
	
	# text
	var _t = Stopwatch.start()
	var text_en = load("res://assets/locales/Pharaoh_Text.en.translation")
	if text_en == null:
		_t = Stopwatch.start()
		text_en = load_text(get_game_file_path("Pharaoh_Text.eng"), "en") # the files are ALWAYS .eng, despite internal docs mentioning otherwise
		if text_en == null:
			Log.error(self, ERR_FILE_NOT_FOUND, "can not find valid localization files in install folder")
			return false
		ResourceSaver.save("res://assets/locales/Pharaoh_Text.en.translation", text_en)
		Stopwatch.stop(self, _t, "extracted Pharaoh_Text into Pharaoh_Text.en.translation")
	else:
		Stopwatch.stop(self, _t, "loaded Pharaoh_Text.en.translation")

	# MM -- TODO
#	var mm_en = load("res://assets/locales/Pharaoh_MM.en.translation")
#	if mm_en == null:
#		mm_en = load_mm(install_path + "/Pharaoh_MM.eng", "en") # the files are ALWAYS .eng, despite internal docs mentioning otherwise
#		if mm_en == null:
#			Log.error(self, ERR_FILE_NOT_FOUND, "can not find valid localization files in install folder")
#			return false
#		ResourceSaver.save("res://assets/locales/Pharaoh_MM.en.translation", mm_en)
	
	TranslationServer.add_translation(text_en)
	TranslationServer.set_locale("en")
	return true
func load_sounds(ignore_cache: bool = false) -> bool: # TODO
	return true
func load_backdrops(ignore_cache: bool = false) -> bool: # this loads the SHARED terrain tilesets
	# load tileset from cache -- around 420~460 ms
	var _t = Stopwatch.start()
	var path_cached_tileset = get_game_cache_path() + "/" + GAME_SET + "_shared.tileset"
	if !ignore_cache && IO.file_exists(path_cached_tileset):
		SHARED_TILESET = IO.read(path_cached_tileset)
		if SHARED_TILESET == null:
			return false
		Stopwatch.stop("load_common_tilesets", _t, "tileset textures loaded from cache")
	else:
		# construct tileset from extracted sprites -- around 1500~1800 ms
		SHARED_TILESET = TileSet.new()
		for pak_name in TILESETS[GAME_SET]:
			if !add_pak_sprites_into_tileset(SHARED_TILESET, pak_name + ".sg3", true):
				return false
		Stopwatch.stop("load_common_tilesets", _t, "tileset textures generated and loaded")
		
		# save tileset as raw Variant disk file -- around ~1200 ms
		_t = Stopwatch.start()
		IO.write(path_cached_tileset, SHARED_TILESET)
		Stopwatch.stop("load_common_tilesets", _t, "tileset save to disk")
	return true
func load_animations(ignore_cache: bool = false) -> bool: # TODO
#	if !load_sgx("SprMain.sg3"): return false
#	if !load_sgx("SprMain2.sg3"): return false
#	get_animated_sprite_texture()
	if get_SG_data("SprMain") == null:
		return false
	if get_SG_data("SprMain2") == null:
		return false
	return true
func load_monuments(ignore_cache: bool = false) -> bool: # this loads the UNLOADED / OVERLAPPING paks into NON-CANON ORDER.
	var _t = Stopwatch.start()
	var path_cached_tileset = get_game_cache_path() + "/" + GAME_SET + "_unloaded.tileset"
	if !ignore_cache && IO.file_exists(path_cached_tileset):
		FULL_TILESET = IO.read(path_cached_tileset)
		if FULL_TILESET == null:
			return false
		Stopwatch.stop("load_unloaded_tilesets", _t, "tileset textures loaded from cache")
	else:
		FULL_TILESET = SHARED_TILESET
		for pak_name in TILESETS[GAME_SET].unloaded:
			if !add_pak_sprites_into_tileset(FULL_TILESET, pak_name + ".sg3", false):
				return false
		Stopwatch.stop("load_unloaded_tilesets", _t, "tileset textures generated and loaded")
		
		_t = Stopwatch.start()
		IO.write(path_cached_tileset, FULL_TILESET)
		Stopwatch.stop("load_unloaded_tilesets", _t, "tileset save to disk")
	return true
func load_enemies(ignore_cache: bool = false) -> bool: # TODO
	return true
func load_settings(ignore_cache: bool = false) -> bool: # TODO
	return true

###

func test_print_sgx():
#	if !extract_full_sgx("Temple_bast.555", true, true):
#		return bail(FAILED, "test failed!!")
	var files = IO.dir_contents(str(Settings.INSTALL_PATH, "/Data")).files
	for f in files:
		if IO.get_extension(f) == "sg3":
			extract_sgx(IO.strip_extension(f))
			var h = SG_CACHE[GAME_SET][IO.strip_extension(f)].header
			print("%-20s %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d" % [
				f,
				h.filesize_sgx,
				h.version,#": file.get_u32(),
				h.unk00,#": file.get_u32(), # ???
				h.img_records_max,#": file.get_i32(),
				h.img_records,#": file.get_i32(),
				h.bmp_records,#": file.get_i32(),
				h.bmp_records_nix_system,#": file.get_i32(),
				h.filesize_total,#": file.get_u32(),
				h.filesize_555,#": file.get_u32(),
				h.filesize_external,#": file.get_u32(),
				h.unk10,#": file.get_32(),
				h.unk11,#": file.get_32(),
				h.unk12,#": file.get_32(),
				h.unk13,#": file.get_32(),
				h.unk14,#": file.get_32(),
				h.unk15,#": file.get_32(),
				h.unk16,
				h.unk17,
				h.unk18,
				h.unk19,
				h.__tag_records,
				h.__external_imgs,
#				h.__total_data,
#				h.__uncompressed_data,
#				h.__compressed_data,
				h.__external_data,
				h.__alpha_data,
			])


func load_game_assets(game):
	set_gameset(game)
	yield(ASYNC_set_game_install_paths(false, "Install Path"), "completed")
	yield(Engine.get_main_loop(), "idle_frame")
	
#	test_print_sgx()
#	if !extract_sg_paks(): # <--- true to force all sprite re-extraction --- TODO: on first game load / data path set (or reset)
#		return bail(FAILED, "load_sg_paks()")

	# pass 'true' to any of the below to ignore cached tiles.

	yield(Game.loading_screen(509, "...", false), "completed")
	if !load_locales():
		return bail(FAILED, "load_locales()")
	
	yield(Game.loading_screen(509, "TEXT_11_5"), "completed")
	yield(Engine.get_main_loop(), "idle_frame")
	if !load_sounds():
		return bail(FAILED, "load_sounds()")
	
	yield(Game.loading_screen(509, "TEXT_11_7"), "completed")
	yield(Engine.get_main_loop(), "idle_frame")
	if !load_backdrops():
		return bail(FAILED, "load_backdrops()")
	
	yield(Game.loading_screen(509, "TEXT_11_8"), "completed")
	yield(Engine.get_main_loop(), "idle_frame")
	if !load_animations():
		return bail(FAILED, "load_animations()")
	yield(Engine.get_main_loop(), "idle_frame")
	
	yield(Game.loading_screen(509, "TEXT_11_9"), "completed")
	yield(Engine.get_main_loop(), "idle_frame")
	if !load_monuments():
		return bail(FAILED, "load_monuments()")
	yield(Engine.get_main_loop(), "idle_frame")
	
	yield(Game.loading_screen(509, "TEXT_11_10"), "completed")
	if !load_enemies():
		return bail(FAILED, "load_enemies()")
	yield(Engine.get_main_loop(), "idle_frame")
	
	yield(Game.loading_screen(509, "TEXT_11_11"), "completed")
	yield(Engine.get_main_loop(), "idle_frame")
	if !load_settings():
		return bail(FAILED, "load_settings()")

func bail(err, msg) -> bool:
	Log.error(self, err, msg)
	assert(false)
	return false
