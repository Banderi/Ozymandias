tool
extends Node

# user / res & game data paths
onready var INSTALL_PATH_SELECT_DIALOG = get_tree().root.get_node("Root/Menus/FileDialog") as FileDialog
const RES_ASSETS_PATH = "res://assets/Pharaoh"
const USER_ASSETS_PATH = "user://assets_cache/"
#var DATA_PATH = null
var SAVES_PATH = null
var GAME_FILES = {} # this is the actual cache list of game files paths, when (if) found
func find_and_record_game_file(file_name: String, subdir: String = ""):
	var path = IO.find_file_recursive(str(Settings.INSTALL_PATH, subdir), file_name)
	if path == null:
		return Log.error(self, GlobalScope.Error.ERR_FILE_NOT_FOUND, "could not find %s within game folders" % [file_name])
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
			
		yield(Engine.get_main_loop(), "idle_frame")
	yield(Engine.get_main_loop(), "idle_frame")
func ASYNC_set_game_install_paths(force_user_select: bool, title_text: String, dialog_text: String = "Please select the folder containing Pharaoh game data.\n"):
	if Settings.INSTALL_PATH == null || force_user_select:
#		DATA_PATH = null
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
			
			
			
			yield(Engine.get_main_loop(), "idle_frame") # this is required because ConfirmationDialogExt continuously fires "chosen" on the same frame
			
		Settings.update("INSTALL_PATH", path)
	else:
		yield(get_tree(), "idle_frame")
	
	# enumerate game files and record their paths
#	DATA_PATH = Settings.INSTALL_PATH + "/Data"
	SAVES_PATH = Settings.INSTALL_PATH + "/Save"
	


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

func load_png(path: String):
	var image = Image.new()
	var r = image.load(path)
	if r != OK:
		return null
	var texture = ImageTexture.new()
	texture.create_from_image(image, Texture.FLAG_MIPMAPS)
	return texture
func load_pak_image():
	pass

# SG "Sierra Graphics" archives
enum ImageTypes {
	Plain_WithTransparency = 0,
	Plain_Opaque = 1,
	Plain_16x16 = 10,
	Plain_24x24 = 12,
	Plain_32x32 = 13, # only used in system.bmp
	Plain_Font = 20,
	Isometric = 30,
	Modded = 40	
}
var SG = {}
const SGX_HEADER_SIZE = 80
const SGX_MAX_BMPS = 300
const SGX_MAX_TAGS = 300
func load_sgx(sgx_file: String, force_extraction: bool = false):
	# original SG format dissection resources:
	# https://github.com/bvschaik/julius/blob/master/src/core/image.c
	# https://github.com/lclarkmichalek/libsg/blob/master/c/sgfile.c
	# https://github.com/bvschaik/citybuilding-tools/wiki/SG-file-format

	# check if already extracted
	var sgx_name = IO.strip_extension(sgx_file)
	if sgx_name in SG && !force_extraction:
		return true

	var _t = Stopwatch.start()
	
	# actual path
	var sgx_path = get_game_file_path(sgx_file)
	if sgx_path == null:
		return false
	Stopwatch.stop(self, _t, "get_game_file_path()")
	
	var file = IO.open(sgx_path, File.READ, true) as FileEx
	if file == null:
		return false
	
	# initialize pak data
	SG[sgx_name] = {
		"header": {},
		"bmp": [],
		"img": [],
		"groups": [],
		"tag_names": []
	}
	var p_sgdata = SG[sgx_name]
	
	# header
	p_sgdata.header = {
		"filesize_sgx": file.get_u32(),
		"version": file.get_u32(),
		"unk00": file.get_u32(), # ???
		"img_records_max": file.get_i32(),
		"img_records": file.get_i32(),
		"bmp_records": file.get_i32(),
		"bmp_records_nix_system": file.get_i32(),
		"filesize_total": file.get_u32(),
		"filesize_555": file.get_u32(),
		"filesize_external": file.get_u32(),
		"unk10": file.get_32(),
		"unk11": file.get_32(),
		"unk12": file.get_32(),
		"unk13": file.get_32(),
		"unk14": file.get_32(),
		"unk15": file.get_32(),
		"unk16": file.get_32(),
		"unk17": file.get_32(),
		"unk18": file.get_32(),
		"unk19": file.get_32()
	}
	
	# tag groups
	for i in p_sgdata.header.bmp_records:
		p_sgdata.groups.push_back(file.get_u16())
	
	# bmp records
	file.push_cursor_base(SGX_HEADER_SIZE + 2 * SGX_MAX_BMPS)
	for i in p_sgdata.header.bmp_records:
		p_sgdata.bmp.push_back({
			"name": file.get_buffer(65).get_string_from_ascii(),
			"comment": file.get_buffer(51).get_string_from_ascii(),
			"width": file.get_u32(),
			"height": file.get_u32(),
			"num_images": file.get_u32(),
			"__num_images_i": 0,
			"index_start": file.get_u32(),
			"index_end": file.get_u32(),
			"unk00": file.get_u32(),  # unknown, img record index
			"unk01": file.get_u32(),
			"unk02": file.get_u32(),
			"unk03": file.get_u32(),  #			8
			"unk04": file.get_u32(),  #			172
			"smallest_img_width": file.get_u32(),
			"smallest_img_height": file.get_u32(),
			
			"unk07": file.get_u32(),  # 39214	897425
			"unk08": file.get_u32(),  # 50124	1575400
			"unk09": file.get_u32(),  # 10910	677975
			
			"unk10": file.get_u32(),  #				10
			"unk11": file.get_u32(),
			"unk12": file.get_u32(),
			"unk13": file.get_u32(),
			"unk14": file.get_u32(),
			"unk15a": file.get_u16(), # 1			1
			"unk15b": file.get_u16()  #				2
		})
	var has_system_bmp = p_sgdata.header.bmp_records > 0 && p_sgdata.bmp[0].name == "system.bmp"
	
	# image data
	var MAX_BMP_RECORDS
	var IMG_RECORD_SIZE = 64
	var include_alpha = false
	if p_sgdata.header.version == 211:
		MAX_BMP_RECORDS = 100 # .sg2
	else:
		MAX_BMP_RECORDS = 200 # .sg3
	if p_sgdata.header.version >= 214:
		include_alpha = true
		IMG_RECORD_SIZE = 72
	file.push_cursor_base(200 * MAX_BMP_RECORDS + IMG_RECORD_SIZE)  # first one is empty/dummy
	p_sgdata.img.push_back(null)
	for i in p_sgdata.header.img_records:
		p_sgdata.img.push_back({
			"__sgx_idx": i, # first one is NULL
			"data_offset": file.get_u32(),
			"data_length": file.get_u32(),
			"uncompressed_length": file.get_u32(),
			"unk00": file.get_32(),
			"offset_mirror": file.get_i32(), # .sg3 only
			"width": max(file.get_i16(), 0),
			"height": max(file.get_i16(), 0),
			"atlas_x": file.get_16(),
			"atlas_y": file.get_16(),
			"name_idx": file.get_16(),
			"animation.num_sprites": file.get_u16(),
			"animation.unk04": file.get_16(),
			"animation.sprite_x_offset": file.get_i16(),
			"animation.sprite_y_offset": file.get_i16(),
			"animation.unk05": file.get_16(),
			"animation.unk06": file.get_16(),
			"animation.unk07": file.get_16(),
			"animation.unk08": file.get_16(),
			"animation.unk09": file.get_16(),
			"animation.can_reverse": file.get_i8(),
			"animation.unk10": file.get_8(),
			"type": file.get_u8(),
			"is_fully_compressed": file.get_i8(),
			"is_external": file.get_i8(),
			"has_isometric_top": file.get_i8(),
			"unk11": file.get_8(),
			"isometric_tile_size": file.get_8(), # not fully consistent?
			"bmp_record": file.get_u8(),
			"unk13": file.get_8(),
			"animation.speed_id": file.get_u8(),
			"unk14": file.get_8(),
			"unk15": file.get_8(),
			"unk16": file.get_8(),
			"unk17": file.get_8(),
			"isometric_multi_tile": file.get_8(),
			"alpha_offset": 0,
			"alpha_length": 0
		})
		var img = p_sgdata.img[-1]
		if include_alpha:
			img.alpha_offset = file.get_i32()
			img.alpha_length = file.get_i32()
		p_sgdata.bmp[img.bmp_record].__num_images_i += 1
		img.idx_in_bmp = p_sgdata.bmp[img.bmp_record].__num_images_i
		
	
	# img names at the end
	file.push_cursor_base((p_sgdata.header.img_records_max - 1) * IMG_RECORD_SIZE)
	for i in SGX_MAX_TAGS: # first field here is also empty/dummy
		p_sgdata.tag_names.push_back(file.get_buffer(48).get_string_from_ascii())
	assert(file.end_reached(true))
	var _t_1 = Stopwatch.query(_t, Stopwatch.Milliseconds)
	
	# =========== .555 pak / actual image data =========== #
	
	file = IO.open(str(IO.naked_folder_path(sgx_path), "/", sgx_name, ".555"), File.READ, true) as FileEx
	if file == null:
		return false
	
	# image data
	var images_skipped = 0
	var i = -1
	for img in p_sgdata.img:
		i += 1
		if img == null || (has_system_bmp && img.bmp_record == 0): # skip system.bmp
			images_skipped += 1
			continue
		
		# convert raw pixel data
		var raw_data = file.get_buffer(4 * img.width * img.height)
		match img.type:
			ImageTypes.Plain_WithTransparency,\
			ImageTypes.Plain_Opaque,\
			ImageTypes.Plain_16x16,\
			ImageTypes.Plain_24x24,\
			ImageTypes.Plain_32x32,\
			ImageTypes.Plain_Font:
				if !img.is_fully_compressed:
					var imgdata = SGImageMono.readPlain(raw_data)
				else: # 256, 257, 276 etc.
					var imgdata = SGImageMono.readSprite(raw_data)
			ImageTypes.Isometric:
				var imgdata = SGImageMono.readIsometric(raw_data)
			_: # unknown image type?
				Log.error(self, GlobalScope.Error.ERR_INVALID_PARAMETER, "unknown image type '%d'" % [img.type])
		if img.get("alpha_length", 0) != 0:
			pass
		if img.offset_mirror != 0:
			pass
	if has_system_bmp:
		assert(images_skipped == p_sgdata.bmp[0].num_images + 1)
	var _t_2 = Stopwatch.query(_t, Stopwatch.Milliseconds)
	
	print("SG pak %-20s ms taken: %3d %3d (%-3d total) %-5d images, %-3d bmps, %-3d groups" % [
		"'" + sgx_name + "'",
		_t_1,
		_t_2 - _t_1,
		_t_2,
		p_sgdata.header.img_records,
		p_sgdata.header.bmp_records_nix_system,
		p_sgdata.groups.size()
	])
#	print("---------------------------------------------------------------------------------------------------------------------------------------------")
#	for r in bmp:
#		print("%-20s %-4d : %-4d %-4d : %-4d %-4d %-4d %-4d : %-4d %-4d %-4d %-4d : %-4d %-3d : %-8d %-8d %-8d %-4d %-4d %-4d %-4d %-4d %-3d %-3d" % [
#			r.name, r.global_group_id,
#			r.width, r.height,
#			r.num_images, r.index_start, r.index_end,
#			r.unk00,
#			r.unk01,
#			r.unk02,
#			r.unk03,
#			r.unk04,
#			r.smallest_img_width,
#			r.smallest_img_height,
#			r.unk07, r.unk08, r.unk09,
#			r.unk10,
#			r.unk11,
#			r.unk12,
#			r.unk13,
#			r.unk14,
#			r.unk15a,
#			r.unk15b,
#		])
#	print("\n")
#	var last_bmp = 0
#	var i_in_bmp = 0
#	for r in img:
#		if last_bmp != r.bmp_record:
#			last_bmp = r.bmp_record
#			i_in_bmp = 0
#		i_in_bmp += 1
#		print("%-2d %-4d %-3d : %-4d %-4d %-4d %-3d : %-4d %-4d %-4d %-4d %-4d %-4d %-2d : %-2d %-2d %-2d %-2d %-2d %-2d %-2d %-2d %s" % [
#			r.bmp_record,
#			r.__sgx_idx,
#			i_in_bmp,
#			r.unk00,
#			r.atlas_x,
#			r.atlas_y,
#			r.name_idx,
#			r["animation.unk04"],
#			r["animation.unk05"],
#			r["animation.unk06"],
#			r["animation.unk07"],
#			r["animation.unk08"],
#			r["animation.unk09"],
#			r["animation.unk10"],
#			r.unk11,
#			r.isometric_tile_size,
#			r.unk13,
#			r.unk14,
#			r.unk15,
#			r.unk16,
#			r.unk17,
#			r.isometric_multi_tile,
#			spr_names[r.name_idx]
#		])
#
#		if r.bmp_record == 4:
#
#			var n = ColorRect.new()
#			n.color = Color8(randi()%255, randi()%255, randi()%255)
#			n.rect_size = Vector2(r.width, r.height)
#			n.rect_position = Vector2(r.atlas_x, r.atlas_y)
#	#		var n = Sprite.new()
#	#		n.centered = false
#	#		n.texture = load_png(
#			Game.TEST_SPR_ATLAS.add_child(n)
#			Game.TEST_SPR_ATLAS.get_node("RECT").rect_size = Vector2(bmp[r.bmp_record].width, bmp[r.bmp_record].height)
#	print("\n")
	return true

const TILE_WIDTH_PIXELS = 60
const TILE_HEIGHT_PIXELS = 30
const HALF_TILE_WIDTH_PIXELS = 30
const HALF_TILE_HEIGHT_PIXELS = 15
func tileset_add_tile_from_sg_image(tileset: TileSet, sgx_name: String, id: int):
	
	#  OPTION 1: read cached raw texture streams -- around ~390 ms
	var path_cached = str(USER_ASSETS_PATH, "/Data/" , sgx_name, "/", id, ".texture")
	var texture = IO.read(path_cached, false, true)
	
	#  OPTION 2: extract from SG paks -- ?? ms
	if texture == null:
		if !load_sgx(sgx_name + ".sg3"): # TODO
			return false
		pass 
	
	# OPTION 3: loading pngs from res:// -- around ~1050 ms
	if texture == null:
		var png_path = str(RES_ASSETS_PATH, "/", sgx_name, "/", id, ".png")
		if IO.file_exists(png_path):
			var image = Image.new()
			var r = image.load(png_path)
			if r != OK:
				return false
			texture = ImageTexture.new()
			texture.create_from_image(image, 0) # MUST NOT HAVE Texture.FLAG_MIPMAPS here.
			IO.write(path_cached, texture, true) # save to cache
	
	# OPTION 4: loading pngs from PharaohExtract -- around ~1050 ms
	if texture == null:

		# compose full path from bmp records
		var img = SG[sgx_name].img[id] # this was enumerated at OPTION 2, so it must be valid.
		var bmp_name = SG[sgx_name].bmp[img.bmp_record].name
		bmp_name = bmp_name.rsplit(".", false, 1)[0]
		var png_path = "D:/PharaohExtract/%s/%s_%05d.png" % [sgx_name, bmp_name, img.idx_in_bmp]
		
		# load from png
		if IO.file_exists(png_path):
			var image = Image.new()
			var r = image.load()
			if r != OK:
				return false
			texture = ImageTexture.new()
			texture.create_from_image(image, 0) # MUST NOT HAVE Texture.FLAG_MIPMAPS here.
			IO.write(path_cached, texture, true) # save to cache
	
	if texture == null: # welp?!???
		return false

	
	# create tile and add texture to tileset
	var tile_size = (texture.get_size().x + 2) / TILE_WIDTH_PIXELS
	tileset.create_tile(id + 14252)
	tileset.tile_set_texture(id + 14252, texture)
	tileset.tile_set_texture_offset(id + 14252, Vector2(0, (15 * (tile_size + 1)) - texture.get_size().y))
	return true

func editor_debug_translate_labels(node):
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

###

func load_locales(): # TODO: MM, check user settings, add different locales
	
	# text
	var _t = Stopwatch.start()
	var text_en = load("res://assets/locales/Pharaoh_Text.en.translation")
	if text_en == null:
		_t = Stopwatch.start()
		text_en = load_text(get_game_file_path("Pharaoh_Text.eng"), "en") # the files are ALWAYS .eng, despite internal docs mentioning otherwise
		if text_en == null:
			Log.error(self, GlobalScope.Error.ERR_FILE_NOT_FOUND, "can not find valid localization files in install folder")
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
#			Log.error(self, GlobalScope.Error.ERR_FILE_NOT_FOUND, "can not find valid localization files in install folder")
#			return false
#		ResourceSaver.save("res://assets/locales/Pharaoh_MM.en.translation", mm_en)
	
	TranslationServer.add_translation(text_en)
	TranslationServer.set_locale("en")
	return true
func load_sounds(): # TODO
	pass
func load_backdrops(): # TODO
	pass
func load_animations(): # TODO
	pass
func load_monuments(): # TODO
	pass
func load_enemies(): # TODO
	pass
func load_settings(): # TODO
	pass
func load_tilesets():
	
	

	# load tileset from raw Variant disk file -- around ~400 ms
	var _t = Stopwatch.start()
	var path_cached_tileset = USER_ASSETS_PATH + "/Data/Pharaoh_Terrain.tileset"
	if IO.file_exists(path_cached_tileset):
		Map.tileset_image = IO.read(path_cached_tileset)
		Stopwatch.stop(self, _t, "tileset textures load")
	else:
		
#		if !load_sgx("Pharaoh_Terrain"): return false
#		if !load_sgx("Pharaoh_General"): return false
#		if !load_sgx("Pharaoh_Unloaded"): return false
#		if !load_sgx("SprMain"): return false
#		if !load_sgx("SprMain2"): return false
		
		# construct tileset from extracted sprites -- 
		var tileset = TileSet.new()
#		for i in range(201, SG.Pharaoh_Terrain.img.size()):
		for i in range(201, 1515 + 1):
			tileset_add_tile_from_sg_image(tileset, "Pharaoh_Terrain", i)
		Map.tileset_image = tileset
		Stopwatch.stop(self, _t, "tileset textures load")
		
		# save tileset as raw Variant disk file -- around ~310 ms
		_t = Stopwatch.start()
		IO.write(path_cached_tileset, tileset)
		Stopwatch.stop(self, _t, "tileset save to disk")
		

#	var tileset = TileSet.new()
#	for i in range(201, SG.Pharaoh_Terrain.img.size()):
#		tileset_add_tile_from_sg_image(tileset, i)
#	Stopwatch.stop(self, _t, "tileset textures load")
#	Map.tileset_image = tileset

	# save tileset as Resource -- around ~4000 ms !!!!!
#	_t = Stopwatch.start()
#	ResourceSaver.save("res://assets/Pharaoh/Tileset_Test4.tres", tileset)
#	Stopwatch.stop(self, _t, "tileset save to disk")

	# save tileset as raw Variant disk file -- around ~310 ms
#	_t = Stopwatch.start()
#	IO.write("res://assets/Pharaoh/Tileset_Test5.tres", tileset)
#	Stopwatch.stop(self, _t, "tileset save to disk")

	# load tileset from Resource -- around ~4000 ms !!!!!
#	var _t = Stopwatch.start()
#	Map.tileset_image = load("res://assets/Pharaoh/Tileset_Test4.tres")
#	Stopwatch.stop(self, _t, "tileset textures load")

	return true

func _ready():
	yield(get_tree(), "idle_frame") # this is required for tree nodes (e.g. FileDialog) to set up before usage.
	yield(ASYNC_set_game_install_paths(false, "Pharaoh Install Path"), "completed")
	
	load_locales()
	load_tilesets()
	emit_signal("ready") # W H Y is this not automatic ?!??!?!?!?????
