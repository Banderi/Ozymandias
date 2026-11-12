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
	GameSet.init_caches()
	
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

# Sierra Graphics paks (.sgx/.555)
func get_sgx_path(pak_name: String):
	var filename_sgx = pak_name + GameSet.get_SG_EXTENSION() # e.g. ".sg3" for Pharaoh
	return get_game_file_path(filename_sgx)
func extract_sgx(pak_name: String):
	var pak_info = GameSet.get_SG_PAK(pak_name)
	if pak_info == null:
		return false
	var path = get_sgx_path(pak_name) # full path to .sgx file
	if path == null:
		return false
	if !SG.open(path): # open & parse pak
		return false
	if !SG.extract_all((true if pak_info[2] >= 201 else false)):
		return false
	var sginfo = SG.get_data() # get full SG data dump from the reader
	if !GameSet.set_SG_CACHE(pak_name, sginfo): # store in memory
		return false
	IO.write(str(get_game_cache_path(), "/Data/" , pak_name, ".CACHED"), sginfo) # try to save to disk, ignoring errors
	
	# dump all extracted textures to disk cache
	for i in sginfo.textures:
		var texture = sginfo.textures[i]
		if texture != null:
			var path_cached = str(get_game_cache_path(), "/Data/", pak_name, "/", i, ".texture")
			IO.write(path_cached, texture, true) # save to cache
	return true
func get_SG_data(pak_name: String): # return (ref) cached SG data
	
	#  OPTION 1: check the data in memory
	var sginfo = GameSet.get_SG_CACHE(pak_name)
	if sginfo != null:
		return sginfo
	
	#  OPTION 2: check cache saved to disk
	var path_cached = str(get_game_cache_path(), "/Data/" , pak_name, ".CACHED")
	var r = IO.read(path_cached, false, true)
	if r != null:
		sginfo = r
		GameSet.set_SG_CACHE(pak_name, sginfo)
		return sginfo
	
	#  OPTION 3: extract from game files
	if !extract_sgx(pak_name):
		return null
	return GameSet.get_SG_CACHE(pak_name) # this MUST succeed if the above succeeds!

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
	if sginfo == null:
		return null
	texture = sginfo.textures.get(img_idx, null)
	if texture != null:
		IO.write(path_cached, texture, true) # save to cache
		return texture
	
	# return results
	if texture == null:
		Log.error("get_SG_texture", ERR_FILE_NOT_FOUND, "could not load game texture %d of pak %s" % [img_idx, pak_name])
	return texture
func get_tagged_SG_img_idx(pak_name: String, tag_idx: int, spr_offset: int):
	var tag = _sg_get_tag_record(pak_name, tag_idx)
	if tag == null:
		return null
	return tag.img + spr_offset
func get_tagged_SG_texture(pak_name: String, tag_idx: int, spr_offset: int, seek_cache_only: bool) -> Texture:
	var img_idx = get_tagged_SG_img_idx(pak_name, tag_idx, spr_offset)
	if img_idx == null:
		return null
	return get_SG_texture(pak_name, img_idx, seek_cache_only)

# gameset-specific SG paks, image id lookups and texture fetch

func get_gameset_SG_img_idx(global_img_id: int): # this takes into account ONLY THE CANON ORDER, and thus ONLY THE FIRST OVERLAPPING PAK FOUND
	var paks_table = GameSet.get_SG_PAK(null)
	if paks_table != null:
		for pak_name in paks_table:
			var pak_range_info = paks_table[pak_name]
			var start_img_id = pak_range_info[0]
			var end_img_id = pak_range_info[1]
			var skip_initial = pak_range_info[2]
			if global_img_id >= start_img_id && global_img_id <= end_img_id:
				return [pak_name, global_img_id - start_img_id + skip_initial]
		Log.error(self, ERR_DOES_NOT_EXIST, "image id '%s' could not be resolved" % [global_img_id])
	return null
func get_gameset_SG_texture(global_img_id: int, seek_cache_only: bool) -> Texture:
	var r = get_gameset_SG_img_idx(global_img_id)
	if r == null:
		return null
	return get_SG_texture(r[0], r[1], seek_cache_only)

# animated sprites: TODO
onready var NULL_SPRITE_ANIM = preload("res://assets/sprite_anim_null.tres")
func build_animated_sprite(pak_name: String, sg_tags: Array): # WARNING-- this can ONLY build from a single pak (for now!) 
	var offsets = {}
	var sprite = SpriteFrames.new()
	for tag in sg_tags:
	
		var pak_table = GameSet.get_SG_ANIMS(pak_name)
		if pak_table == null:
			return null
		if tag >= pak_table.size():
			return Log.error("load_animated_sprite", ERR_DOES_NOT_EXIST, " no known info for animation at tag=%d inside '%s'" % [tag, pak_name])
		var anim_info = pak_table[tag]
		var directions = anim_info[0]
		var frames = anim_info[1]
		
		for dir in directions:
			var anim_name = str(sg_tags.find(tag), "_", dir)
			var anim_offsets = []
			sprite.add_animation(anim_name)
			
			for f in frames:
				var img_idx = get_tagged_SG_img_idx(pak_name, tag, dir + f * directions)
				var texture = get_SG_texture(pak_name, img_idx, false)
				if texture == null:
					break
				sprite.add_frame(anim_name, texture)
				
				# sprite offsets
				# https://github.com/Banderi/Ozymandias_Julius/blob/master/src/graphics/boilerplate.cpp#L699
				var img = _sg_get_img_record(pak_name, img_idx)
				var sprite_offset = Vector2(img.anim_sprite_x_offset, img.anim_sprite_y_offset)
				if img.offset_to_mirror_sprite != 0:
					img = _sg_get_img_record(pak_name, img_idx + img.offset_to_mirror_sprite)
					sprite_offset.x = img.width - img.anim_sprite_x_offset
				anim_offsets.push_back(sprite_offset)
				
			offsets[anim_name] = (anim_offsets)
	
	sprite.set_meta("offsets", offsets) # if this had not been possible, I don't know what I would have done!!
	return sprite
func get_animated_sprite(pak_name: String, sprite_name: String, seek_cache_only: bool) -> SpriteFrames:
	
	#  OPTION 1: read cache from memory
	var sprite = GameSet.get_SPRITES_CACHE(sprite_name)
	if sprite != null:
		return sprite

	#  OPTION 2: read cache from disk
	var path_cached = str(get_game_cache_path(), "/Data/", pak_name, "/", sprite_name, ".sprite")
	sprite = IO.read(path_cached, false, true)
	if sprite != null || seek_cache_only:
		GameSet.set_SPRITES_CACHE(sprite_name, sprite)
		return sprite

	#  OPTION 3: construct from extracted SG data
	var spr_cc = sprite_name.split("_")
	if spr_cc.size() != 2:
		return null
	var category = spr_cc[0]
	var anim_cc_idx = int(spr_cc[1])
	var sg_tags = GameSet.get_ANIM_LOOKUP(category, anim_cc_idx)
	if sg_tags == null:
		return NULL_SPRITE_ANIM
	sprite = build_animated_sprite(pak_name, sg_tags)
	if sprite != null:
		IO.write(path_cached, sprite, true) # save to cache # <---------------------------
		GameSet.set_SPRITES_CACHE(sprite_name, sprite)
		return sprite
	
	return NULL_SPRITE_ANIM
#	return null

# tiles and tileset ops
const TILE_WIDTH_PIXELS = 60
const TILE_HEIGHT_PIXELS = 30
const HALF_TILE_WIDTH_PIXELS = 30
const HALF_TILE_HEIGHT_PIXELS = 15
const TILE_PROGRESS_TICK = Vector2(0, 0)
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
	var pak_range_info = GameSet.get_SG_PAK(pak_name)
	if pak_range_info == null:
		Log.error("add_pak_sprites_into_tileset", ERR_DOES_NOT_EXIST, "file '%s' not found in gameset pak records" % [pak_name])
		return false
	
	var global_start_img_id = pak_range_info[0]
	var global_end_img_id = pak_range_info[1]
	var skip_initial = pak_range_info[2]
		
	
	# get .sgx header data
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
func load_backdrops(ignore_cache: bool = false) -> bool: # this loads the SHARED terrain GameSet.TILESETS
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
		var tileset_paks = GameSet.get_TILESETS("shared")
		if tileset_paks == null:
			return false
		for pak_name in tileset_paks:
			if !add_pak_sprites_into_tileset(SHARED_TILESET, pak_name + ".sg3", true):
				return false
		Stopwatch.stop("load_common_tilesets", _t, "tileset textures generated and loaded")
		
		# save tileset as raw Variant disk file -- around ~1200 ms
		_t = Stopwatch.start()
		IO.write(path_cached_tileset, SHARED_TILESET)
		Stopwatch.stop("load_common_tilesets", _t, "tileset save to disk")
	return true
func load_animations(ignore_cache: bool = false) -> bool: # TODO
#	if get_SG_data("SprMain") == null:
#		return false
#	if get_SG_data("SprMain2") == null:
#		return false
	
#	var figure_anims = GameSet.get_ANIM_LOOKUP("Figures")
#	if figure_anims == null:
#		return false
#
#	for i in figure_anims.size():
#		var anim_name = str(i, "_", Debug.CS_ENUMS.FigureTypes.get(i, null))
#		print(anim_name)
#		if get_animated_sprite("SprMain", anim_name, figure_anims[i], false) == null:
#			return false
	
#	if get_animated_sprite("SprMain", "Figures_69", false) == null:
#		return false
	
#	if get_animated_sprite("SprMain", "ostrich", [156, 157, 158, 159, 160], false) == null:
#		return false
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
		var tileset_paks = GameSet.get_TILESETS("unloaded")
		if tileset_paks == null:
			return false
		for pak_name in tileset_paks:
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
			var h = get_SG_data(IO.strip_extension(f)).header
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
