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
func load_pak_image():
	pass

# SG graphics / paks
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
func load_sgx(pak_name: String, data_path: String = DATA_PATH, sg_ext: String = ".sg3", data_ext: String = ".555"): # code from https://github.com/lclarkmichalek/libsg/blob/master/c/sgfile.c
	var _t = Stopwatch.start()
	
	var file = IO.open(data_path + "/" + pak_name + sg_ext, File.READ, "", true) as File
	if file == null:
		return false
	file.set_script(preload("res://scripts/classes/FileEx.gd"))
	file = file as FileEx
	
	# initialize pak data
	SG[pak_name] = {
		"header": {},
		"bmp": [],
		"img": [],
		"groups": [],
		"tag_names": []
	}
	var p_pak = SG[pak_name]
	
	# header
	p_pak.header = {
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
	for i in p_pak.header.bmp_records:
		p_pak.groups.push_back(file.get_u16())
	
	# bmp records
	file.push_cursor_base(SGX_HEADER_SIZE + 2 * SGX_MAX_BMPS)
	for i in p_pak.header.bmp_records:
		p_pak.bmp.push_back({
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
	var has_system_bmp = p_pak.header.bmp_records > 0 && p_pak.bmp[0].name == "system.bmp"
	
	# image data
	var MAX_BMP_RECORDS
	var IMG_RECORD_SIZE = 64
	var include_alpha = false
	if p_pak.header.version == 211:
		MAX_BMP_RECORDS = 100 # .sg2
	else:
		MAX_BMP_RECORDS = 200 # .sg3
	if p_pak.header.version >= 214:
		include_alpha = true
		IMG_RECORD_SIZE = 72
	file.push_cursor_base(200 * MAX_BMP_RECORDS + IMG_RECORD_SIZE)  # first one is empty/dummy
	p_pak.img.push_back(null)
	for i in p_pak.header.img_records:
		p_pak.img.push_back({
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
		var img = p_pak.img[-1]
		if include_alpha:
			img.alpha_offset = file.get_i32()
			img.alpha_length = file.get_i32()
		p_pak.bmp[img.bmp_record].__num_images_i += 1
		img.idx_in_bmp = p_pak.bmp[img.bmp_record].__num_images_i
		
	
	# img names at the end
	file.push_cursor_base((p_pak.header.img_records_max - 1) * IMG_RECORD_SIZE)
	for i in SGX_MAX_TAGS: # first field here is also empty/dummy
		p_pak.tag_names.push_back(file.get_buffer(48).get_string_from_ascii())
	assert(file.end_reached(true))
	var _t_1 = Stopwatch.query(_t, Stopwatch.Milliseconds)
	
	# =========== .555 pak / actual image data =========== #
	
	file = IO.open(data_path + "/" + pak_name + data_ext, File.READ, "", true) as File
	if file == null:
		return false
	file.set_script(preload("res://scripts/classes/FileEx.gd"))
	file = file as FileEx
	
	# image data
	var images_skipped = 0
	var i = -1
	for img in p_pak.img:
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
		assert(images_skipped == p_pak.bmp[0].num_images + 1)
	var _t_2 = Stopwatch.query(_t, Stopwatch.Milliseconds)
	
	print("SG pak %-20s ms taken: %3d %3d (%-3d total) %-5d images, %-3d bmps, %-3d groups" % [
		"'" + pak_name + "'",
		_t_1,
		_t_2 - _t_1,
		_t_2,
		p_pak.header.img_records,
		p_pak.header.bmp_records_nix_system,
		p_pak.groups.size()
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

func tileset_add_tile_from_sg_image(tileset: TileSet, id: int, path: String):
	tileset.create_tile(id)
	var texture = load_png(path)
	tileset.tile_set_texture(id, texture)
	tileset.tile_set_texture_offset(id, Vector2(0, 30 - texture.get_size().y))

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
func load_locales(install_path: String = INSTALL_PATH): # TODO: MM, check user settings, add different locales
	
	# text
	var text_en = load("res://assets/locales/Pharaoh_Text.en.translation")
	if text_en == null:
		text_en = load_text(install_path + "/Pharaoh_Text.eng", "en") # the files are ALWAYS .eng, despite internal docs mentioning otherwise
		if text_en == null:
			Log.error(self, GlobalScope.Error.ERR_FILE_NOT_FOUND, "can not find valid localization files in install folder")
			return false
		ResourceSaver.save("res://assets/locales/Pharaoh_Text.en.translation", text_en)

	# MM
#	var mm_en = load("res://assets/locales/Pharaoh_MM.en.translation") # TODO
#	if mm_en == null:
#		mm_en = load_mm(install_path + "/Pharaoh_MM.eng", "en") # the files are ALWAYS .eng, despite internal docs mentioning otherwise
#		if mm_en == null:
#			Log.error(self, GlobalScope.Error.ERR_FILE_NOT_FOUND, "can not find valid localization files in install folder")
#			return false
#		ResourceSaver.save("res://assets/locales/Pharaoh_MM.en.translation", mm_en)
	
	TranslationServer.add_translation(text_en)
	TranslationServer.set_locale("en")
	return true
func load_sounds(install_path: String = INSTALL_PATH): # TODO
	pass
func load_backdrops(install_path: String = INSTALL_PATH): # TODO
	pass
func load_animations(install_path: String = INSTALL_PATH): # TODO
	pass
func load_monuments(install_path: String = INSTALL_PATH): # TODO
	pass
func load_enemies(install_path: String = INSTALL_PATH): # TODO
	pass
func load_settings(install_path: String = INSTALL_PATH): # TODO
	pass
func load_tilesets(install_path: String = INSTALL_PATH):
	
	if !load_sgx("Pharaoh_Terrain"): return false
#	if !load_sgx("Pharaoh_General"): return false
#	if !load_sgx("Pharaoh_Unloaded"): return false
#	if !load_sgx("SprMain"): return false
#	if !load_sgx("SprMain2"): return false
	
	
	# testing
#	var tileset = TileSet.new()
#	for i in range(201, SG.Pharaoh_Terrain.img.size()):
#		var img = SG.Pharaoh_Terrain.img[i]
#		var bmp_name = SG.Pharaoh_Terrain.bmp[img.bmp_record].name
#		bmp_name = bmp_name.rsplit(".", false, 1)[0]
#		var path = "D:/PharaohExtract/Pharaoh_Terrain/%s_%05d.png" % [bmp_name, img.idx_in_bmp]
#		tileset_add_tile_from_sg_image(tileset, i + 14252, path)
#	ResourceSaver.save("res://assets/Tileset_Test2.tres", tileset)
#	Map.tileset_flat = tileset
	Map.tileset_flat = load("res://assets/Tileset_Test2.tres")
	
	return true
