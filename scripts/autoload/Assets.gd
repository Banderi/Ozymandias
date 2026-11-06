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
	
	Map.init()
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
			
		yield(Engine.get_main_loop(), "idle_frame")
	yield(Engine.get_main_loop(), "idle_frame")
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

# SG "Sierra Graphics" archives parsing and raw record ops
# original SG format dissection resources:
# https://github.com/bvschaik/julius/blob/master/src/core/image.c
# https://github.com/lclarkmichalek/libsg/blob/master/c/sgfile.c
# https://github.com/bvschaik/citybuilding-tools/wiki/SG-file-format
enum ImageTypes {
	Plain_WithTransparency = 0,
	Plain_Opaque = 1,
	Plain_16x16 = 10,
	Plain_24x24 = 12,
	Plain_32x32 = 13, # only used in system.bmp
	Plain_Font = 20,
	Isometric = 30, }
var SG = {}
func _sg_get_img_record(filename_sgx: String, img_idx: int):
	# naked SG pak name
	var pak_name = IO.strip_extension(filename_sgx)
	if filename_sgx == pak_name:
		return Log.error("parse_sgx", ERR_INVALID_PARAMETER, "full filename with extension is required but was provided the naked pak_name")

	# check if already parsed
	if !(pak_name in SG):
		if !parse_full_sgx(pak_name + ".sg3"):
			return null
	
	# get img record (if present)
	if img_idx >= SG[pak_name].img.size():
		return Log.error("_sg_get_img_record", ERR_DOES_NOT_EXIST, "pak '%s' does not contain any image at index %d" % [filename_sgx, img_idx])
	return SG[pak_name].img[img_idx] # first one is a dummy BUT it is present, so the array MATCHES the naive alignment!
func _sg_get_bmp_record(filename_sgx: String, bmp_idx: int):
	# naked SG pak name
	var pak_name = IO.strip_extension(filename_sgx)
	if filename_sgx == pak_name:
		return Log.error("parse_sgx", ERR_INVALID_PARAMETER, "full filename with extension is required but was provided the naked pak_name")

	# check if already parsed
	if !(pak_name in SG):
		if !parse_full_sgx(pak_name + ".sg3"):
			return null
	
	# get bmp record (if present)
	if bmp_idx >= SG[pak_name].bmp.size():
		return Log.error("_sg_get_img_record", ERR_DOES_NOT_EXIST, "pak '%s' does not contain any bitmap at index %d" % [filename_sgx, bmp_idx])
	return SG[pak_name].bmp[bmp_idx]
func _sg_get_tag_record(filename_sgx: String, tag_idx: int):
	# naked SG pak name
	var pak_name = IO.strip_extension(filename_sgx)
	if filename_sgx == pak_name:
		return Log.error("parse_sgx", ERR_INVALID_PARAMETER, "full filename with extension is required but was provided the naked pak_name")

	# check if already parsed
	if !(pak_name in SG):
		if !parse_full_sgx(pak_name + ".sg3"):
			return null
	
	# get tag record (if present)
	if tag_idx >= SG[pak_name].tag.size() || SG[pak_name].tag[tag_idx] == null:
		return Log.error("_sg_get_img_record", ERR_DOES_NOT_EXIST, "pak '%s' does not contain any valid tag (group) at index %d" % [filename_sgx, tag_idx])
	return SG[pak_name].tag[tag_idx]
func _sg_img_get_external_555(img: Dictionary):
	return IO.strip_extension(img.__bmp_name) + ".555"
func _image_from_raw_sg_data(raw_data: PoolByteArray, img: Dictionary, alpha_data) -> Image:
	var extracted_image: Image = null
	match img.type:
		ImageTypes.Plain_WithTransparency,\
		ImageTypes.Plain_Opaque,\
		ImageTypes.Plain_16x16,\
		ImageTypes.Plain_24x24,\
		ImageTypes.Plain_32x32,\
		ImageTypes.Plain_Font:
			if !img.has_compressed_alpha:
				extracted_image = SGImageMono.ReadPlain(raw_data, img.width, img.height) as Image
			else: # 256, 257, 276 etc.
				extracted_image = SGImageMono.ReadWithCompressedAlpha(raw_data, img.width, img.height) as Image
		ImageTypes.Isometric: # TODO: set isometric tile width/height by gameset 
			extracted_image = SGImageMono.ReadIsometric(raw_data, img.uncompressed_length, img.width, img.height, img.isometric_tile_size, 30, 58) as Image
		_: # unknown image type?
			return Log.error(self, ERR_INVALID_PARAMETER, "unknown image type '%d'" % [img.type])
	if alpha_data != null:
		SGImageMono.SetAlphaMask(extracted_image, img.width, alpha_data)
	return extracted_image
func parse_full_sgx(filename_sgx: String, force_reparse: bool = false) -> bool: # .sgx head
#	return parse_sgx_2(filename_sgx, force_reparse)
#	Log.generic("parse_sgx", "filename_sgx:%s, force_reparse:%s" % [filename_sgx, force_reparse])
	var _t = Stopwatch.start()

	# naked SG pak name
	var pak_name = IO.strip_extension(filename_sgx)
	if filename_sgx == pak_name:
		Log.error("parse_sgx", ERR_INVALID_PARAMETER, "full filename with extension is required but was provided the naked pak_name")
		return false

	# check if already parsed
	if pak_name in SG && !force_reparse:
		return true

	# actual path
	var path = get_game_file_path(filename_sgx)
	if path == null:
		return false

	# open .sgx file
	var file = IO.open(path, File.READ, true) as FileEx
	if file == null:
		return false

	# initialize pak data
	SG[pak_name] = {
		"header": {},
		"bmp": [],
		"img": [],
		"tag": [],
#		"tags": {},
#		"tag_names": {}
	}
	var p_data = SG[pak_name]

	# header
	p_data.header = {
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
		"unk19": file.get_32(),
		"__tag_records": 0, # set later!
		"__external_imgs": 0, # set later!
#		"__uncompressed_data": 0, # set later!
#		"__compressed_data": 0, # set later!
#		"__total_data": 0, # set later!
		"__external_data": 0, # set later!
		"__alpha_data": 0, # set later!
	}

	# file offsets
	var MAX_TAGS = 300
	var MAX_IMG_RECORDS = SG[pak_name].header.img_records_max
	var MAX_BMP_RECORDS = 200 # .sg3
	if SG[pak_name].header.version == 211:
		MAX_BMP_RECORDS = 100 # .sg2
	
	var BMP_RECORD_SIZE = 200
	var alpha_mask_extra = false
	var IMG_RECORD_SIZE = 64
	if SG[pak_name].header.version >= 214:
		alpha_mask_extra = true
		IMG_RECORD_SIZE = 72
	var TAG_NAME_SIZE = 48
	
	var OFFSET_TAGS = 80
	var OFFSET_BMP_RECORDS = OFFSET_TAGS + (MAX_TAGS * 2)
	var OFFSET_IMG_RECORDS = OFFSET_BMP_RECORDS + (MAX_BMP_RECORDS * BMP_RECORD_SIZE)
#	var OFFSET_TAG_NAMES = OFFSET_IMG_RECORDS + (MAX_IMG_RECORDS * IMG_RECORD_SIZE)
	var OFFSET_TAG_NAMES = OFFSET_IMG_RECORDS + (p_data.header.img_records_max * IMG_RECORD_SIZE)
	
	# tags (aka "groups")
#	file.push_cursor_base(OFFSET_TAGS)
#	for i in p_data.header.bmp_records:
	for i in MAX_TAGS:
#		p_data.groups.push_back(file.get_u16())
		var tag_image_idx = file.get_u16()
		if tag_image_idx != 0:
			p_data.tag.push_back({
				"img": tag_image_idx
			})
			p_data.header.__tag_records += 1
#			p_data.tags[i] = tag_image_idx
		else:
			p_data.tag.push_back(null)

	# bmp records
#	file.push_cursor_base(OFFSET_BMP_RECORDS)
#	file.seek(OFFSET_BMP_RECORDS)
	for i in p_data.header.bmp_records:
		p_data.bmp.push_back({
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

	# image data
#	file.push_cursor_base(BMP_RECORD_SIZE * MAX_BMP_RECORDS + IMG_RECORD_SIZE)  # first one is empty/dummy
	file.seek(OFFSET_IMG_RECORDS + IMG_RECORD_SIZE)
	p_data.img.push_back(null)
	for i in range(1, p_data.header.img_records + 1): # first one is NULL so the i is off-by-one
		p_data.img.push_back({
			"__sgx_idx": i,
			"data_offset": file.get_u32(),
			"data_length": file.get_u32(),
			"uncompressed_length": file.get_u32(),
			"unk00": file.get_32(),
			"offset_to_mirror_sprite": file.get_i32(), # .sg3 only
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
			"has_compressed_alpha": file.get_i8(), # aka is_fully_compressed
			"is_external": file.get_i8(),
			"has_isometric_top": file.get_i8(), # aka has_compressed_part 
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
		var img = p_data.img[-1]
		img["__bmp_name"] = p_data.bmp[img.bmp_record].name
		if alpha_mask_extra:
			img.alpha_offset = file.get_i32()
			img.alpha_length = file.get_i32()
		if img.is_external:
			p_data.header.__external_imgs += 1
			p_data.header.__external_data += img.data_length
#		p_data.header.__total_data += img.data_length
#		p_data.header.__uncompressed_data += img.uncompressed_length
#		p_data.header.__compressed_data += img.data_length - img.uncompressed_length
		p_data.header.__alpha_data += img.alpha_length
		p_data.bmp[img.bmp_record].__num_images_i += 1
		img.idx_in_bmp = p_data.bmp[img.bmp_record].__num_images_i

	# tag names at the end
#	file.push_cursor_base((p_data.header.img_records_max - 1) * IMG_RECORD_SIZE)
#	for i in MAX_TAGS: # first field here is also empty/dummy
	for i in p_data.tag.size(): # first field here is also empty/dummy
#		p_data.tag_names.push_back(file.get_buffer(48).get_string_from_ascii())
#		p_data.group_names.push_back(file.get_buffer(48).get_string_from_ascii())
		var tag = p_data.tag[i]
		if tag != null:
			file.seek(OFFSET_TAG_NAMES + TAG_NAME_SIZE * i)
			var tag_name = file.get_buffer(TAG_NAME_SIZE).get_string_from_ascii()
			tag["name"] = tag_name
#	assert(file.end_reached(true))
	var _t_1 = Stopwatch.query(_t, Stopwatch.Milliseconds)

#	Log.generic("parse_sgx", "DONE (%d ms) -- %d images, %d bmps, %d tags" % [
#		Stopwatch.query(_t, Stopwatch.Milliseconds),
#		p_data.header.img_records,
#		p_data.header.bmp_records_nix_system,
#		p_data.header.__tag_records
#	])
	file.close()
	if force_reparse:
		return p_data.header.img_records
	else:
		return true
func extract_full_sgx(filename_555: String, skip_system_bmp: bool, force_reextract: bool) -> bool: # .555 pak / actual image data
	
#	Log.generic("extract_sgx", "filename_555:%s, skip_system_bmp:%s, force_reextract:%s" % [filename_555, skip_system_bmp, force_reextract])
	var _t = Stopwatch.start()
	
	# naked SG pak name
	var pak_name = IO.strip_extension(filename_555)
	if filename_555 == pak_name:
		Log.error("extract_sgx", ERR_INVALID_PARAMETER, "full filename with extension is required but was provided the naked pak_name")
		return false

	# check if already parsed
	if !(pak_name in SG):
		if !parse_full_sgx(pak_name + ".sg3"):
			return false
	
	# actual path
	var path = get_game_file_path(filename_555)
	if path == null:
		return false
	
	# open .555 file
	var file = IO.open(path, File.READ, true) as FileEx
	if file == null:
		return false
	
	var p_data = SG[pak_name]
	var has_system_bmp = p_data.header.bmp_records > 0 && p_data.bmp[0].name == "system.bmp"
	
	# image data
	var images_skipped = 0
	var images_extracted = 0
	var images_failed = 0
	var images_external = 0
	var i = -1
	for img in p_data.img:
		i += 1
		if img == null || (has_system_bmp && img.bmp_record == 0 && skip_system_bmp): # skip system.bmp
			images_skipped += 1
			continue
		
		if img.is_external: # TODO
			images_external += 1
			continue
		
		if img.data_length == 0:
			images_failed += 1
			continue
		
		# check if image is already in cache
		var path_cached = str(get_game_cache_path(), "/Data/" , pak_name, "/", i, ".texture")
		if !force_reextract && IO.file_exists(path_cached):
			images_skipped += 1
			continue
		
		# mirrored sprite
		if img.offset_to_mirror_sprite != 0:
			pass # TODO
		
		# convert raw pixel data
		var raw_data_size = img.data_length
		file.seek(img.data_offset)
		var raw_data = file.get_buffer(raw_data_size)
		var alpha_data = file.get_buffer(img.alpha_length) if img.alpha_length != 0 else null
		var extracted_image = _image_from_raw_sg_data(raw_data, img, alpha_data)
		
		# save extracted texture to disk
		if extracted_image != null:
			var texture = ImageTexture.new()
			texture.create_from_image(extracted_image, 0)
			if !IO.write(path_cached, texture, true):
				return false
			images_extracted += 1
		else:
			images_failed += 1
	
	Log.generic("extract_sgx", "DONE (%d ms) -- %d extracted, %d skipped, %d failed" % [
		Stopwatch.query(_t, Stopwatch.Milliseconds),
		images_extracted,
		images_skipped,
		images_failed
	])
	file.close()
	if force_reextract:
		return images_extracted
	else:
		return true

func extract_single_sg_texture(filename_sgx: String, img_idx: int) -> Texture: # TODO
	var _t = Stopwatch.start()
	
	# get img record
	var img = _sg_get_img_record(filename_sgx, img_idx)
	if img == null:
		return null
	
	# mirrored sprite
	var is_mirrored = (img.offset_to_mirror_sprite != 0)
	if is_mirrored:
		img = _sg_get_img_record(filename_sgx, img_idx + img.offset_to_mirror_sprite)
		if img == null:
			return null
	
	if img.data_length == 0:
		return Log.error("extract_single_sg_texture", ERR_INVALID_DATA, "image record %d of pak %s is invalid/empty (data_length=0)" % [img_idx, filename_sgx])
	
	# determine external .555 pak source
	var filename_555 = null
	if img.is_external:
		filename_555 = _sg_img_get_external_555(img)
	else:
		filename_555 = IO.strip_extension(filename_sgx) + ".555"
	
	# bitmap texture data from .555
	var path = get_game_file_path(filename_555) # actual path
	if path == null:
		return null
	var file = IO.open(path, File.READ, true) as FileEx # open .555 file
	if file == null:
		return null
	
	# convert raw pixel data
	if img.is_external:
		file.seek(img.data_offset - 1)
	else:
		file.seek(img.data_offset)
	var raw_data = file.get_buffer(img.data_length)
	var alpha_data = file.get_buffer(img.alpha_length) if img.alpha_length != 0 else null
	file.close()
	
	# convert into usable ImageTexture
	var extracted_image = _image_from_raw_sg_data(raw_data, img, alpha_data)
	var texture = null
	if extracted_image != null:
		texture = ImageTexture.new()
		if is_mirrored:
			extracted_image.flip_x()
		texture.create_from_image(extracted_image, 0)
	if texture == null:
		return null
	
	# success!
	Log.generic("extract_single_sg_texture", "Extracted img %d from '%s' (%d ms)" % [
		img_idx,
		filename_sgx,
		Stopwatch.query(_t, Stopwatch.Milliseconds)
	])
	return texture
func get_sg_texture(filename_sgx: String, img_idx: int, seek_cache_only: bool) -> Texture: # this uses the pak's own record indices -- it COUNTS SYSTEM.BMP AS WELL AS THE DUMMY RECORD.
	
	#  OPTION 1: read cached raw texture streams -- around ~380 ms
	var pak_name = IO.strip_extension(filename_sgx)
	if filename_sgx == pak_name:
		return Log.error("get_sg_texture", ERR_INVALID_PARAMETER, "full filename with extension is required but was provided the naked pak_name")
	var path_cached = str(get_game_cache_path(), "/Data/", pak_name, "/", img_idx, ".texture")
	var texture = IO.read(path_cached, false, true)
	if texture != null || seek_cache_only:
		return texture
	
	#  OPTION 2: extract from SG paks -- ?? ms
	texture = extract_single_sg_texture(filename_sgx, img_idx)
	if texture != null:
		IO.write(path_cached, texture, true) # save to cache
		return texture
	
	# return results
	if texture == null:
		Log.error("get_sg_texture", ERR_FILE_NOT_FOUND, "could not load game texture %d of pak %s" % [img_idx, pak_name])
	return texture
func get_tagged_sg_texture_idx(filename_sgx: String, tag_idx: int, spr_offset: int):
	var tag = _sg_get_tag_record(filename_sgx, tag_idx)
	if tag == null:
		return null
	return tag.img + spr_offset
func get_tagged_sg_texture(filename_sgx: String, tag_idx: int, spr_offset: int, seek_cache_only: bool) -> Texture:
	var img_idx = get_tagged_sg_texture_idx(filename_sgx, tag_idx, spr_offset)
	if img_idx == null:
		return null
	return get_sg_texture(filename_sgx, img_idx, seek_cache_only)

# gameset-specific SG paks, image id lookups and texture fetch
const SG_PAKS = { # These are the ranges of game paks and how they're laid out in the global image lookup.
				  #                       start id        final id      start       end
	"Pharaoh": [  #                       (global)        (global)      (pak)      (pak)
		["Pharaoh_Unloaded.sg3", 			    1,            682,         1,       682],
		["SprMain.sg3", 					  683,          11007,         1,     10325],
		
		["Assyrian.sg3",					11008,          11906,         1,       899],
		["Enemy_1.sg3",						11008,          11736,         1,       729],
		["Canaanite.sg3",					11008,          11866,         1,       859],
		["Hittite.sg3",						11008,          11874,         1,       867],
		["Hyksos.sg3",						11008,          11906,         1,       899],
		["Kushite.sg3",						11008,          11866,         1,       859],
		["Libian.sg3",						11008,          11866,         1,       859],
		["Mitani.sg3",						11008,          11906,         1,       899],
		["Nubian.sg3",						11008,          11834,         1,       827],
		["Persian.sg3",						11008,          11874,         1,       867],
		["Phoenician.sg3",					11008,          11842,         1,       835],
		["Roman.sg3",						11008,          11882,         1,       875],
		["SeaPeople.sg3",					11008,          11841,         1,       834],
		
		["Pharaoh_General.sg3",				11907,          14452,       201,      2746],
		["Pharaoh_Terrain.sg3",				14453,          15767,       201,      1515],
		
		["sphinx1a.sg3",					15768,          15769,       201,       202],
		["sphinx1b.sg3",					15770,          15771,       201,       202],
		["sphinx1c.sg3",					15772,          15773,       201,       202],
		["sphinx1d.sg3",					15774,          15775,       201,       202],
		
		["obelisk5x5a.sg3",					15768,          15768,       201,       201],
		["obelisk3x3a.sg3",					15770,          15770,       201,       201],
		["obelisk_extra.sg3",				15776,          15791,       201,       216],
		
		["Temple_nile.sg3",					15792,          15829,       201,       238],
		["Temple_ra.sg3",					15792,          15829,       201,       238],
		["Temple_ptah.sg3",					15792,          15829,       201,       238],
		["Temple_seth.sg3",					15792,          15829,       201,       238],
		["Temple_bast.sg3",					15792,          15829,       201,       238],
		
		["Empire.sg3",						15830,          15830,       201,       201],
		
		["SprAmbient.sg3",					15831,          18764,         1,      2934],
		["Pharaoh_Fonts.sg3",				18765,          20104,       201,      1540],
		["Egyptian.sg3",					20105,          20883,         1,       779],
		["SprMain2.sg3",					20884,          23235,         1,      2352],
		["Expansion.sg3",					23236,          23935,       201,       900],
		
		["Pyramid.sg3",						23936,          24163,       201,       428],
		["Mastaba.sg3",						23936,          24935,       201,       900],
		["PyramidDummy.sg3",				23936,          24163,       201,       428],
		# ?? (dummy yellow squares until end)
		# canonical end = 25139
		
		# ---------------- non-canon order override!! ---------------- #
		
#		["Pyramid.sg3",						30000,          30227,       201,       428],

	] }
func extract_sg_paks(force_reextract: bool = false): # parse sgx records AND extract images to cache, if missing
	var _t = Stopwatch.start()
	for i in SG_PAKS[GAME_SET].size():
		var pak_range_info = SG_PAKS[GAME_SET][i]
		
		var filename_sgx = pak_range_info[0]
		var start_img_id = pak_range_info[1]
		var end_img_id = pak_range_info[2]
		var skip_initial = pak_range_info[3]
		var total_img_records = pak_range_info[4]
		
		var r = parse_full_sgx(filename_sgx, true)
		if r != total_img_records:
			return false
		if r + start_img_id - skip_initial != end_img_id:
			var shouldvebeen = r + start_img_id - skip_initial
			return false
		var pak_name = IO.strip_extension(filename_sgx)
		if !extract_full_sgx(pak_name + ".555", (true if skip_initial >= 201 else false), force_reextract):
			return false
	Stopwatch.stop("load_sg_paks", _t, "SG paks loaded for game '%s'" % [GAME_SET])
	return true
func get_gameset_sg_texture(img_id: int): # this takes into account ONLY THE CANON ORDER, and thus ONLY THE FIRST OVERLAPPING PAK FOUND
	if GAME_SET in SG_PAKS:
		for i in SG_PAKS[GAME_SET].size():
			var pak_range_info = SG_PAKS[GAME_SET][i]
			var filename_sgx = pak_range_info[0]
			var start_img_id = pak_range_info[1]
			var end_img_id = pak_range_info[2]
			var skip_initial = pak_range_info[3]
			if img_id >= start_img_id && img_id <= end_img_id:
				return get_sg_texture(filename_sgx, img_id - start_img_id + skip_initial, false)
		Log.error(self, ERR_DOES_NOT_EXIST, "image id '%s' could not be resolved" % [img_id])
	else:
		Log.error(self, ERR_METHOD_NOT_FOUND, "game set '%s' is not implemented" % [GAME_SET])
	return null

# animated sprites: TODO
func get_animated_sprite_texture(filename_sgx: String, img_idx: int, seek_cache_only: bool):
	var img = _sg_get_img_record(filename_sgx, img_idx)
	var bmp = _sg_get_bmp_record(filename_sgx, 1)
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
#		texture = get_sg_texture("Pharaoh_Terrain.sg3", 850)					 # upon applying certain textures. e.g.:
	var tile_size = (texture.get_size().x + 2) / TILE_WIDTH_PIXELS				 # - Pharaoh_Terrain @ 850 (SPR_B_DOCK_E)
	tileset.create_tile(id)
	tileset.tile_set_texture(id, texture)
	tileset.tile_set_texture_offset(id, Vector2(0, (15 * (tile_size + 1)) - texture.get_size().y))
func add_pak_sprites_into_tileset(tileset: TileSet, filename_sgx: String, canon_sequence: bool) -> bool: # DO NOT USE this on a tileset IN USE in a TileMap! DETACH it first!!
	var _t = Stopwatch.start()
	if tileset == null:
		Log.error("add_pak_sprites_into_tileset", ERR_INVALID_PARAMETER, "tileset parameter was passed null")
		return false
	
	# find pak info in gameset records
	var pak_range_info = null
	if canon_sequence:
		for i in SG_PAKS[GAME_SET].size():
			pak_range_info = SG_PAKS[GAME_SET][i]
			if pak_range_info[1] >= 30000:
				break
			if filename_sgx != pak_range_info[0]:
				pak_range_info = null
			else:
				break
		if pak_range_info == null:
			Log.error("add_pak_sprites_into_tileset", ERR_DOES_NOT_EXIST, "file '%s' not found in gameset pak records" % [filename_sgx])
			return false
	else:
		for i in range(SG_PAKS[GAME_SET].size()-1, -1, -1):
			pak_range_info = SG_PAKS[GAME_SET][i]
			if pak_range_info[1] < 30000:
				break
			if filename_sgx != pak_range_info[0]:
				pak_range_info = null
			else:
				break
		if pak_range_info == null:
			Log.error("add_pak_sprites_into_tileset", ERR_DOES_NOT_EXIST, "file '%s' not found in gameset pak records" % [filename_sgx])
			return false
	
	var global_start_img_id = pak_range_info[1]
	var global_end_img_id = pak_range_info[2]
	var skip_initial = pak_range_info[3]
		
	
	# get .sgx header data
	var pak_name = IO.strip_extension(filename_sgx) # naked SG pak name
	if !(pak_name in SG) || !("header" in SG[pak_name]): # check if data was already parsed
		if !parse_full_sgx(filename_sgx):
			return false
	var pak_header = SG[pak_name].header
	
	# load images within the boundaries of the global ids of this pak
	var replaced = 0
	var skipped = 0
	var last_img_id = null
	for i in range(skip_initial, pak_header.img_records + 1): # img_records does NOT include the dummy image at #0
		var texture = get_sg_texture(filename_sgx, i, true)
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
		Log.error("add_pak_sprites_into_tileset", ERR_BUG, "pak '%s' image ids do not add up as expected (%d != %d)" % [filename_sgx, last_img_id, global_end_img_id])
		return false
	Log.generic("add_pak_sprites_into_tileset", "'%s' (%d ms) -- tiles %d --> %d, %d replaced, %d skipped" % [
		filename_sgx,
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
			parse_full_sgx(f)
			var h = SG[IO.strip_extension(f)].header
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
