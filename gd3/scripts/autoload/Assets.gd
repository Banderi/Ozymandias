tool
extends Node

# TODO: put these in user setting
const INSTALL_PATH = "D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra" 
const DATA_PATH = INSTALL_PATH + "/Data"
const SAVES_PATH = INSTALL_PATH + "/Save"

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

func load_png(path):
	var image = Image.new()
	image.load(path)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	return texture

const SGX_HEADER_SIZE = 80
const SGX_MAX_GROUPS = 300
func load_sgx(path_sgx: String, path_pak: String): # code from https://github.com/lclarkmichalek/libsg/blob/master/c/sgfile.c
	var file = IO.open(path_sgx, File.READ) as File
	if file == null:
		return false
	file.set_script(preload("res://scripts/classes/FileEx.gd"))
	file = file as FileEx
	
	# header
	var header = {
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
	
	# bmp group image ids
	var bmp = []
	for i in header.bmp_records:
		bmp.push_back({ "image_id": file.get_u16() })
	
	# bmp records
	file.push_cursor_base(SGX_HEADER_SIZE + 2 * SGX_MAX_GROUPS)
	for i in header.bmp_records:
		bmp[i].merge({
			"name": file.get_buffer(65).get_string_from_ascii(),
			"comment": file.get_buffer(51).get_string_from_ascii(),
			"width": file.get_u32(),
			"height": file.get_u32(),
			"num_images": file.get_u32(),
			"index_start": file.get_u32(),
			"index_end": file.get_u32()
		})
	
	# image data
	var MAX_BMP_RECORDS
	var IMG_RECORD_SIZE = 64
	var include_alpha = false
	if header.version == 211:
		MAX_BMP_RECORDS = 100 # .sg2
	else:
		MAX_BMP_RECORDS = 200 # .sg3
	if header.version >= 214:
		include_alpha = true
		IMG_RECORD_SIZE = 72
	file.push_cursor_base(200 * MAX_BMP_RECORDS + IMG_RECORD_SIZE)  # first one is empty/dummy
	var img = []
	for i in header.img_records:
		img.push_back({
			"sgx_data_offset": file.get_u32(),
			"data_length": file.get_u32(),
			"uncompressed_length": file.get_u32(),
			"unk00": file.get_32(),
			"offset_mirror": file.get_i32(), # .sg3 only
			"width": max(file.get_i16(), 0),
			"height": max(file.get_i16(), 0),
			"unk01": file.get_16(),
			"unk02": file.get_16(),
			"unk03": file.get_16(),
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
			"unk12": file.get_8(),
			"bmp_record_id": file.get_u8(),
			"unk13": file.get_8(),
			"animation.speed_id": file.get_u8(),
			"unk14": file.get_8(),
			"unk15": file.get_8(),
			"unk16": file.get_8(),
			"unk17": file.get_8(),
			"unk18": file.get_8()
		})
		if include_alpha:
			img[i]["alpha_offset"] = file.get_i32()
			img[i]["alpha_length"] = file.get_i32()
	
	# img names at the end
	file.push_cursor_base(header.img_records_max * IMG_RECORD_SIZE - IMG_RECORD_SIZE + 48)
	for i in header.img_records:
		img[i]["name"] = file.get_buffer(48).get_string_from_ascii()
	assert(file.eof_reached())
	
	# =========== .555 / image data pak =========== #
	
	file = IO.open(path_pak, File.READ) as File
	if file == null:
		return false
	file.set_script(preload("res://scripts/classes/FileEx.gd"))
	file = file as FileEx
	
	# image data
	for image in img:
		var data = file.get_buffer(4 * image.width * image.height)
		match image.type:
			0, 1, 10, 12, 13:
				pass
			30:
				pass
			256, 257, 276:
				pass
			_: # unknown image type?
				continue
		if image.alpha_length != 0:
			pass
		if image.offset_mirror:
			pass
	
	
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
	var file = IO.open(path, File.READ)
	if file == null:
		return null
	file.set_script(preload("res://scripts/classes/FileEx.gd"))
	file = file as FileEx

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
	var file = IO.open(path, File.READ) as File
	if file == null:
		return null
	file.set_script(preload("res://scripts/classes/FileEx.gd"))
	file = file as FileEx
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

func set_game_install_path(): # TODO
	pass
func load_locales(data_path: String = INSTALL_PATH): # TODO: MM, check user settings, add different locales
	
	# text
	var text_en = load("res://assets/locales/Pharaoh_Text.en.translation")
	if text_en == null:
		text_en = load_text(data_path + "/Pharaoh_Text.eng", "en") # the files are ALWAYS .eng, despite internal docs mentioning otherwise
		if text_en == null:
			Log.error(self, GlobalScope.Error.ERR_FILE_NOT_FOUND, "can not find valid localization files in install folder")
			return false
		ResourceSaver.save("res://assets/locales/Pharaoh_Text.en.translation", text_en)

	# MM
#	var mm_en = load("res://assets/locales/Pharaoh_MM.en.translation") # TODO
#	if mm_en == null:
#		mm_en = load_mm(data_path + "/Pharaoh_MM.eng", "en") # the files are ALWAYS .eng, despite internal docs mentioning otherwise
#		if mm_en == null:
#			Log.error(self, GlobalScope.Error.ERR_FILE_NOT_FOUND, "can not find valid localization files in install folder")
#			return false
#		ResourceSaver.save("res://assets/locales/Pharaoh_MM.en.translation", mm_en)
	
	TranslationServer.add_translation(text_en)
	TranslationServer.set_locale("en")
	return true
func load_sounds(data_path: String = INSTALL_PATH): # TODO
	pass
func load_backdrops(data_path: String = INSTALL_PATH): # TODO
	pass
func load_animations(data_path: String = INSTALL_PATH): # TODO
	pass
func load_monuments(data_path: String = INSTALL_PATH): # TODO
	pass
func load_enemies(data_path: String = INSTALL_PATH): # TODO
	pass
func load_settings(data_path: String = INSTALL_PATH): # TODO
	pass
func load_tilesets(data_path: String = INSTALL_PATH):
	
	if !load_sgx(data_path + "/Data/Pharaoh_Terrain.sg3", data_path + "/Data/Pharaoh_Terrain.555"):
		return false
	
	
	# testing
	var tileset = TileSet.new()
	tileset.create_tile(0)
	tileset.tile_set_texture(0, load_png("D:/PharaohExtract/Pharaoh_Terrain/FloodPlain_00001.png"))
	
	Map.tileset_flat = tileset
	
	return true
