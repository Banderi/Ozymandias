extends Node

# SG "Sierra Graphics" archives parsing and raw record ops
# original SG format dissection resources:
# https://github.com/bvschaik/julius/blob/master/src/core/image.c
# https://github.com/lclarkmichalek/libsg/blob/master/c/sgfile.c
# https://github.com/bvschaik/citybuilding-tools/wiki/SG-file-format
var _PAK_NAME = null
var _PAK_PATH = null
var _SGX_PATH = null
func open(path: String) -> bool:
	# close first any open file
	if _SGX_PATH != null:
		close()

	# open new file -- attempt parsing the headers
	_SGX_PATH = path
	_PAK_NAME = IO.strip_extension(IO.naked_filename(path))
	_PAK_PATH = IO.naked_folder_path(path)
	if !_parse_headers():
		close()
		return false
	return true
func close():
	_file_close()
	_DATA = null
	_PAK_NAME = null
	_PAK_PATH = null
	_SGX_PATH = null

# low-level file handle interface
var _FILE_HANDLE: FileEx = null
var _FILE_OPEN_PATH = null
func _file_open(path: String) -> bool:
	if path != _FILE_OPEN_PATH:
		_FILE_HANDLE = IO.open(path, File.READ, true)
		if _FILE_HANDLE == null:
			_file_close()
			return false
		_FILE_OPEN_PATH = path
	return true
func _file_close():
	if _FILE_HANDLE != null:
		_FILE_HANDLE.close()
	_FILE_OPEN_PATH = null

var _DATA = null # .SGX header data
func _parse_headers() -> bool:
	var _t = Stopwatch.start()

	# open .sgx file
	if !_file_open(_SGX_PATH):
		return false

	# initialize pak data
	_DATA = {
		"header": {},
		"bmp": [],
		"img": [],
		"tag": [],
		#
		"atlas": null
	}

	# header
	_DATA.header = {
		"filesize_sgx": _FILE_HANDLE.get_u32(),
		"version": _FILE_HANDLE.get_u32(),
		"unk00": _FILE_HANDLE.get_u32(), # this seems to be unused?
		"img_records_max": _FILE_HANDLE.get_i32(),
		"img_records": _FILE_HANDLE.get_i32(),
		"bmp_records": _FILE_HANDLE.get_i32(),
		"bmp_records_nix_system": _FILE_HANDLE.get_i32(),
		"filesize_total": _FILE_HANDLE.get_u32(), # this is the sum of the two values below.
		"filesize_555": _FILE_HANDLE.get_u32(), # this IS the total size of internal (same-name .555) data.
		"filesize_something": _FILE_HANDLE.get_u32(), # this is NOT the total size of external-marked data. it's likely some dev thing, like BMP size
		"unk10": _FILE_HANDLE.get_32(), # these are likely unused values.
		"unk11": _FILE_HANDLE.get_32(),
		"unk12": _FILE_HANDLE.get_32(),
		"unk13": _FILE_HANDLE.get_32(),
		"unk14": _FILE_HANDLE.get_32(),
		"unk15": _FILE_HANDLE.get_32(),
		"unk16": _FILE_HANDLE.get_32(),
		"unk17": _FILE_HANDLE.get_32(),
		"unk18": _FILE_HANDLE.get_32(),
		"unk19": _FILE_HANDLE.get_32(),
		"__tag_records": 0, # set later!
		"__external_imgs": 0, # set later!
		"__external_data": 0, # set later!
		"__alpha_data": 0, # set later!
	}

	# file offsets
	var MAX_TAGS = 300
	var MAX_IMG_RECORDS = _DATA.header.img_records_max
	var MAX_BMP_RECORDS = 200 # .sg3
	if _DATA.header.version == 211:
		MAX_BMP_RECORDS = 100 # .sg2
	
	var BMP_RECORD_SIZE = 200
	var alpha_mask_extra = false
	var IMG_RECORD_SIZE = 64
	if _DATA.header.version >= 214:
		alpha_mask_extra = true
		IMG_RECORD_SIZE = 72
	var TAG_NAME_SIZE = 48
	
	var OFFSET_TAGS = 80
	var OFFSET_BMP_RECORDS = OFFSET_TAGS + (MAX_TAGS * 2) #									80 + 300 * 2		= 80 + 600		= 680
	var OFFSET_IMG_RECORDS = OFFSET_BMP_RECORDS + (MAX_BMP_RECORDS * BMP_RECORD_SIZE) #		680 + 200 * 200		= 680 + 40000	= 40680
	var OFFSET_TAG_NAMES = OFFSET_IMG_RECORDS + (MAX_IMG_RECORDS * IMG_RECORD_SIZE) #		40680 + ?? * 72		= 40680 + ??	= ??
	
	# tags (aka "groups")
	for i in MAX_TAGS:
		var tag_image_idx = _FILE_HANDLE.get_u16()
		if tag_image_idx != 0:
			_DATA.tag.push_back({
				"img": tag_image_idx
			})
			_DATA.header.__tag_records += 1
		else:
			_DATA.tag.push_back(null)

	# bmp records
	for i in MAX_BMP_RECORDS: # NO DUMMY FIELD HERE
		_DATA.bmp.push_back({
			"name": _FILE_HANDLE.get_buffer(65).get_string_from_ascii(),
			"comment": _FILE_HANDLE.get_buffer(51).get_string_from_ascii(),
			"width": _FILE_HANDLE.get_u32(),
			"height": _FILE_HANDLE.get_u32(),
			"num_images": _FILE_HANDLE.get_u32(),
			"__num_images_i": 0,
			"index_start": _FILE_HANDLE.get_u32(),
			"index_end": _FILE_HANDLE.get_u32(),
			"unk00": _FILE_HANDLE.get_u32(),  # unknown, img record index
			"unk01": _FILE_HANDLE.get_u32(),
			"unk02": _FILE_HANDLE.get_u32(),
			"unk03": _FILE_HANDLE.get_u32(),  #			8
			"unk04": _FILE_HANDLE.get_u32(),  #			172
			"smallest_img_width": _FILE_HANDLE.get_u32(),
			"smallest_img_height": _FILE_HANDLE.get_u32(),

			"unk07": _FILE_HANDLE.get_u32(),  # 39214	897425
			"unk08": _FILE_HANDLE.get_u32(),  # 50124	1575400
			"unk09": _FILE_HANDLE.get_u32(),  # 10910	677975

			"unk10": _FILE_HANDLE.get_u32(),  #				10
			"unk11": _FILE_HANDLE.get_u32(),
			"unk12": _FILE_HANDLE.get_u32(),
			"unk13": _FILE_HANDLE.get_u32(),
			"unk14": _FILE_HANDLE.get_u32(),
			"unk15a": _FILE_HANDLE.get_u16(), # 1			1
			"unk15b": _FILE_HANDLE.get_u16()  #				2
		})

	# image data
	_DATA.img.push_back(null)
	_FILE_HANDLE.seek(OFFSET_IMG_RECORDS + IMG_RECORD_SIZE)
	for i in range(1, _DATA.header.img_records + 1): # first one is NULL so the i is off-by-one
		_DATA.img.push_back({
			"__sgx_idx": i,
			"data_offset": _FILE_HANDLE.get_u32(),
			"data_length": _FILE_HANDLE.get_u32(),
			"uncompressed_length": _FILE_HANDLE.get_u32(),
			"unk00": _FILE_HANDLE.get_32(),
			"offset_to_mirror_sprite": _FILE_HANDLE.get_i32(), # .sg3 only
			"width": max(_FILE_HANDLE.get_i16(), 0),
			"height": max(_FILE_HANDLE.get_i16(), 0),
			"atlas_x": _FILE_HANDLE.get_16(),
			"atlas_y": _FILE_HANDLE.get_16(),
			"name_idx": _FILE_HANDLE.get_16(),
			"anim_num_sprites": _FILE_HANDLE.get_u16(),
			"unk04": _FILE_HANDLE.get_16(),
			"anim_sprite_x_offset": _FILE_HANDLE.get_i16(),
			"anim_sprite_y_offset": _FILE_HANDLE.get_i16(),
			"unk05": _FILE_HANDLE.get_16(),
			"unk06": _FILE_HANDLE.get_16(),
			"unk07": _FILE_HANDLE.get_16(),
			"unk08": _FILE_HANDLE.get_16(),
			"unk09": _FILE_HANDLE.get_16(),
			"anim_can_reverse": _FILE_HANDLE.get_i8(),
			"unk10": _FILE_HANDLE.get_8(),
			"type": _FILE_HANDLE.get_u8(),
			"has_compressed_alpha": _FILE_HANDLE.get_i8(), # aka is_fully_compressed
			"is_external": _FILE_HANDLE.get_i8(),
			"has_isometric_top": _FILE_HANDLE.get_i8(), # aka has_compressed_part 
			"unk11": _FILE_HANDLE.get_8(),
			"isometric_tile_size": _FILE_HANDLE.get_8(), # not fully consistent?
			"bmp_record": _FILE_HANDLE.get_u8(),
			"unk13": _FILE_HANDLE.get_8(),
			"anim_speed_id": _FILE_HANDLE.get_u8(),
			"unk14": _FILE_HANDLE.get_8(),
			"unk15": _FILE_HANDLE.get_8(),
			"unk16": _FILE_HANDLE.get_8(),
			"unk17": _FILE_HANDLE.get_8(),
			"isometric_multi_tile": _FILE_HANDLE.get_8(),
			"alpha_offset": 0,
			"alpha_length": 0
		})
		var img = _DATA.img[-1]
		img["__bmp_name"] = _DATA.bmp[img.bmp_record].name
		if alpha_mask_extra:
			img.alpha_offset = _FILE_HANDLE.get_i32()
			img.alpha_length = _FILE_HANDLE.get_i32()
		if img.is_external:
			_DATA.header.__external_imgs += 1
			_DATA.header.__external_data += img.data_length
		_DATA.header.__alpha_data += img.alpha_length
		_DATA.bmp[img.bmp_record].__num_images_i += 1
		img.idx_in_bmp = _DATA.bmp[img.bmp_record].__num_images_i

	# tag names at the end
	for i in _DATA.header.__tag_records + 1: # first field here is also empty/dummy
		var tag = _DATA.tag[i]
		if tag != null:
			_FILE_HANDLE.seek(OFFSET_TAG_NAMES + TAG_NAME_SIZE * i)
			var tag_name = _FILE_HANDLE.get_buffer(TAG_NAME_SIZE).get_string_from_ascii()
			tag["name"] = tag_name
			_DATA.img[tag.img]["__tag_name"] = tag_name
#	assert(_FILE_HANDLE.end_reached(true))
	var _t_1 = Stopwatch.query(_t, Stopwatch.Milliseconds)
	_file_close()

	Log.generic("parse_sgx", "DONE (%d ms) -- %d images, %d bmps, %d tags" % [
		Stopwatch.query(_t, Stopwatch.Milliseconds),
		_DATA.header.img_records,
		_DATA.header.bmp_records_nix_system,
		_DATA.header.__tag_records
	])
	return true
func get_data():
	return _DATA.duplicate() if _DATA != null else null

enum ImageTypes {
	Plain_WithTransparency = 0,
	Plain_Opaque = 1,
	Plain_16x16 = 10,
	Plain_24x24 = 12,
	Plain_32x32 = 13, # only used in system.bmp
	Plain_Font = 20,
	Isometric = 30, }
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
func _extract_img(i: int) -> Image:
	
	var img = _DATA.img[i]
	
	# open .555 file
	if !img.is_external: # marked as internal (same-name .555 file)
		if !_file_open(_PAK_PATH + _PAK_NAME + ".555"):
			return null
	else: # marked as external (separate .555 file, named after the BMP group)
		if !_file_open(_PAK_PATH + IO.strip_extension(img.__bmp_name) + ".555"):
			return null
	
	# mirrored sprite
	var is_mirrored = img.offset_to_mirror_sprite != 0
	if is_mirrored:
		img = _DATA.img[i + img.offset_to_mirror_sprite]

	# check if img data is valid
	if !is_mirrored && img.data_length == 0:
		return Log.warning("SG._extract_img", "img %d does not contain valid data (data_length=0)" % [i])
	
	# convert raw pixel data
	var raw_data_size = img.data_length
	_FILE_HANDLE.seek(img.data_offset - (1 if img.is_external else 0))
	var raw_data = _FILE_HANDLE.get_buffer(raw_data_size)
	var alpha_data = _FILE_HANDLE.get_buffer(img.alpha_length) if img.alpha_length != 0 else null
	var extracted_image = _image_from_raw_sg_data(raw_data, img, alpha_data)
	if extracted_image == null:
		return Log.error("SG._extract_img._image_from_raw_sg_data", FAILED, "could not extract image %d from raw data" % [i])
	
	# return image data
	if is_mirrored:
		extracted_image.flip_x()
	return extracted_image
func _convert_to_texture(image_data: Image) -> ImageTexture:
	if image_data == null:
		return Log.error("SG._convert_to_texture", FAILED, "invalid image data (image_data=null)")
	var texture = ImageTexture.new()
	texture.create_from_image(image_data, 0)
	if texture == null:
		return Log.error("SG._convert_to_texture", FAILED, "could not convert image data into a texture")
	return texture
func _construct_atlas(images: Dictionary, sizes: PoolVector2Array, indices: Dictionary):
	if sizes.size() == 0:
		return null
	
	# TODO: move this to C#? I have no way of checking for failures here.....
	# sprites MUST not be larger than 4096 horizontally -- https://github.com/godotengine/godot/issues/93795
	var atlas_desc = Geometry.make_atlas(sizes) # seems like make_atlas() has a fixed limit of 4096 internally..?
	
	var size_limit = Viewports.get_max_texture_size()
	if atlas_desc.size.x > size_limit || atlas_desc.size.y > size_limit:
		return Log.error("SG._construct_atlas", FAILED, "could not fit within GPU limits (size=%s, limit=%d)" % [atlas_desc.size, size_limit])

	var atlas_rects = {}

	# combine into a single Image
	var atlas_image = Image.new()
	atlas_image.create(atlas_desc.size.x, atlas_desc.size.y, false, Image.FORMAT_RGBA8)
	for i in images:
		var idx = indices[i]
		var p = atlas_desc.points[idx]
		var s = sizes[idx]
		atlas_rects[i] = Rect2(p, s)
		atlas_image.blit_rect(images[i], Rect2(Vector2(), s), p)
	
	# create ImageTexture
	var atlas_texture = _convert_to_texture(atlas_image)
	if atlas_texture == null:
		return null
	
	return {
		"texture": atlas_texture,
		"rects": atlas_rects,
		"images": images
	}
	
func extract_single(img_idx: int) -> Texture:
	var _t = Stopwatch.start()

	# attempt extracting
	var image = _extract_img(img_idx)
	if image == null:
		return null
	
	# convert image to texture
	var texture = _convert_to_texture(image)
	if texture == null:
		return null
	
	# success!
	Log.generic("SG.extract_single", "Extracted img %d from '%s' (%d ms)" % [
		img_idx,
		_PAK_NAME,
		Stopwatch.query(_t, Stopwatch.Milliseconds)
	])
	_DATA.textures[img_idx] = texture
	return texture
func extract_all(skip_system_bmp: bool) -> Texture: # .555 pak / actual image data
	var _t = Stopwatch.start()
	
	var has_system_bmp = _DATA.header.bmp_records > 0 && _DATA.bmp[0].name == "system.bmp"
	
	# image data
	var images_skipped = 0
	var images_extracted = 0
	var images_failed = 0
	var images_external = 0
	var extracted_images = {}
	var extracted_img_sizes = PoolVector2Array()
	var extracted_img_indices = {}
	for i in range(_DATA.img.size()):
		
		# get img field
		var img = _DATA.img[i]
		if img == null || (has_system_bmp && img.bmp_record == 0 && skip_system_bmp): # skip system.bmp
			images_skipped += 1
			continue
		if img.is_external:
			images_external += 1
		
		# attempt extracting
		var image = _extract_img(i)
		if image == null:
			images_failed += 1
		else:
			var img_size = image.get_size()
			if img_size.x > 4096:
				_file_close()
				return Log.error("SG.extract_all", FAILED, "sprite %d exceeding 4096 (width=%d)" % [i, img_size.x])
			if img_size.x < 1 || img_size.y < 1:
				return Log.error("SG.extract_all", FAILED, "sprite %d was extracted, but has invalid size (%s)" % [i, img_size])
			images_extracted += 1
			extracted_images[i] = image
			extracted_img_indices[i] = extracted_img_sizes.size()
			extracted_img_sizes.push_back(image.get_size())

	# close final file handle
	_file_close()
	
	# build texture atlas
	_DATA.atlas = _construct_atlas(extracted_images, extracted_img_sizes, extracted_img_indices)
	
	Log.generic("SG.extract_all", "DONE (%d ms) -- %d extracted, %d skipped, %d failed" % [
		Stopwatch.query(_t, Stopwatch.Milliseconds),
		images_extracted,
		images_skipped,
		images_failed
	])
	
	return _DATA.atlas.texture
