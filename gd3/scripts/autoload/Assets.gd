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

func load_texture(pak = "Pharaoh_Unloaded", data = "0_fired_00001.png"):
	var path = "res://assets/Pharaoh/" + pak + "/" + data
	
	
	var r = load(path)
	if r == null:
		var image = Image.new()
		image.load(path)
		var texture = ImageTexture.new()
		texture.create_from_image(image)
		r = texture
	
	return r

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
	var file = IO.open(path)
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
	
	return tr
func load_mm(path: String):
	var file = IO.open(path) as File
	if file == null:
		return false
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
	pass


###

func set_game_install_path(): # TODO
	pass
func load_locales(data_path: String = INSTALL_PATH):
	
	# TODO: check user settings for different locales
	
	# text
	var text_en = load("res://assets/locales/Pharaoh_Text.en.translation")
	if text_en == null:
		text_en = load_text(data_path + "/Pharaoh_Text.eng", "en") # the files are ALWAYS .eng, despite internal docs mentioning otherwise
		if text_en == null:
			Log.error(self, GlobalScope.Error.ERR_FILE_NOT_FOUND, "can not find valid localization files in install folder")
			return false
		ResourceSaver.save("res://assets/locales/Pharaoh_Text.en.translation", text_en)

	
	TranslationServer.add_translation(text_en)
	TranslationServer.set_locale("en")
	return true
