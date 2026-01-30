extends Node

const DATA_PATH = "D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra/Data" # TODO: put this in user setting

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


# generics
func MAX(bs):
	return (1 << bs)
func u_to_i(unsigned, bs):
	return (unsigned + MAX(bs-1)) % MAX(bs) - MAX(bs-1)
func buffer_padded(arr : PoolByteArray, size):
	var s = size - arr.size()
	if s > 0:
		var t = PoolByteArray()
		t.resize(s)
		t.fill(0)
		arr.append_array(t)
	return arr

# SCRIBE
var scrf_path = null
var scrf_handle = null
var scrf_size = null
var scrf_flags = null
func scribe_open(flags, path, offset = 0):
	scrf_handle = File.new()
	var r = scrf_handle.open(path, flags)
	if r != OK:
		Log.error(null, r, str("could not open file handle '",path,"'"))
		scribe_close()
		return null
	scrf_flags = flags
	scrf_size = scrf_handle.get_len()
	Log.generic("Scribe", "opening \"%s\" (%s bytes)" % [path, scrf_size])
	scribe_set_offset(offset)
	return scrf_size
func scribe_set_offset(offset):
	if offset < 0 || offset > scrf_size:
		return false
	scrf_handle.seek(offset)
	return true
func scribe_close():
	scrf_handle.close()
	scrf_handle = null
	scrf_path = null
	scrf_size = null
	scrf_flags = null
	scrf_curr_chunk_path = null
	
var scrf_curr_chunk_path = null
func scribe_sync_chunk(chunk_path: Array, leaf_type):
	if chunk_path.size() < 1:
		Log.error("Scribe", GlobalScope.Error.ERR_INVALID_PARAMETER, "the supplied path is empty")
		return false
	
	# reset chunk ref
	scrf_curr_chunk_path = null
	
	
	# root -- this MUST be a reference-able object (dict or array)
	var root = chunk_path[0]
	if !(root is Dictionary || root is Array):
		Log.error("Scribe", GlobalScope.Error.ERR_INVALID_PARAMETER, "the supplied root is invalid (%s)" % [root])
		return false
	scrf_curr_chunk_path = root
	
	# traverse the rest of the path / tree
	for i in range(1, chunk_path.size()):
		var key = chunk_path[i]
		
		# node is describing an array element
		if key is int:
			if !(scrf_curr_chunk_path is Array):
				Log.error("Scribe", GlobalScope.Error.ERR_INVALID_PARAMETER, "the key '%s' requires a parent of type Array" % [key])
				return false
			if scrf_curr_chunk_path.size() < key + 1:
				
				if i < chunk_path.size() - 1:
					match typeof(chunk_path[i + 1]):
						TYPE_STRING:
							scrf_curr_chunk_path.push_back({})
						TYPE_INT:
							scrf_curr_chunk_path.push_back([])
						_:
							Log.error("Scribe", GlobalScope.Error.ERR_INVALID_PARAMETER, "the key '%s' is describing a disallowed type (%s)" % [chunk_path[i + 1], typeof(chunk_path[i + 1])])
							return false
				else:
					match leaf_type:
						TYPE_DICTIONARY:
							scrf_curr_chunk_path.push_back({})
						TYPE_ARRAY:
							scrf_curr_chunk_path.push_back([])
						_:
							Log.error("Scribe", GlobalScope.Error.ERR_INVALID_PARAMETER, "the leaf type '%s' is not allowed" % [leaf_type])
							return false
		
		# node is describint a dictionary element
		elif key is String:
			if !(scrf_curr_chunk_path is Dictionary):
				Log.error("Scribe", GlobalScope.Error.ERR_INVALID_PARAMETER, "the key '%s' requires a parent of type Dictionary" % [key])
				return false
			
			if !scrf_curr_chunk_path.has(key):
				
				if i < chunk_path.size() - 1:
					match typeof(chunk_path[i + 1]):
						TYPE_STRING:
							scrf_curr_chunk_path[key] = {}
						TYPE_INT:
							scrf_curr_chunk_path[key] = []
						_:
							Log.error("Scribe", GlobalScope.Error.ERR_INVALID_PARAMETER, "the key '%s' is describing a disallowed type (%s)" % [chunk_path[i + 1], typeof(chunk_path[i + 1])])
							return false
				else:
					match leaf_type:
						TYPE_DICTIONARY:
							scrf_curr_chunk_path[key] = {}
						TYPE_ARRAY:
							scrf_curr_chunk_path[key] = []
						_:
							Log.error("Scribe", GlobalScope.Error.ERR_INVALID_PARAMETER, "the leaf type '%s' is not allowed" % [leaf_type])
							return false
			
		# move the leaf ref along
		scrf_curr_chunk_path = scrf_curr_chunk_path[key]
	
	return true

func scribe_do(key, format, format_extra = null, default = 0):
	if scrf_handle == null:
		Log.error("Scribe", GlobalScope.Error.ERR_LOCKED, "the file handle is uninitialized or invalid (%s)" % [scrf_handle])
		return false
	
	if scrf_curr_chunk_path == null || !(scrf_curr_chunk_path is Dictionary || scrf_curr_chunk_path is Array):
		Log.error("Scribe", GlobalScope.Error.ERR_INVALID_DATA, "the last synced chunk is invalid (%s)" % [scrf_curr_chunk_path])
		return false
	if scrf_curr_chunk_path is Dictionary:
		if !(key is String):
			Log.error("Scribe", GlobalScope.Error.ERR_INVALID_PARAMETER, "the parent chunk (Dictionary) requires a key of type String")
			return false
		if !scrf_curr_chunk_path.has(key):
			scrf_curr_chunk_path[key] = default
	if scrf_curr_chunk_path is Array:
		if !(key is int):
			Log.error("Scribe", GlobalScope.Error.ERR_INVALID_PARAMETER, "the parent chunk (Array) requires a key of type Int")
			return false
		if scrf_curr_chunk_path.size() <= key:
			scrf_curr_chunk_path.push_back(default)
	
	if scrf_flags == File.READ:
		match format:
			Scribe.i8:
				scrf_curr_chunk_path[key] = scrf_handle.get_8()
			Scribe.u8:
				scrf_curr_chunk_path[key] = u_to_i(scrf_handle.get_8(), 8)
			Scribe.i16:
				scrf_curr_chunk_path[key] = scrf_handle.get_16()
			Scribe.u16:
				scrf_curr_chunk_path[key] = u_to_i(scrf_handle.get_16(), 16)
			Scribe.i32:
				scrf_curr_chunk_path[key] = scrf_handle.get_32()
			Scribe.u32:
				scrf_curr_chunk_path[key] = u_to_i(scrf_handle.get_32(), 32)
				
			Scribe.ascii:
				scrf_curr_chunk_path[key] = scrf_handle.get_buffer(format_extra).get_string_from_ascii()
			Scribe.utf8:
				scrf_curr_chunk_path[key] = scrf_handle.get_buffer(format_extra).get_string_from_utf8()
			Scribe.raw:
				scrf_curr_chunk_path[key] = scrf_handle.get_buffer(format_extra)
	else:
		match format:
			# these do not have an unsigned version (TODO?)
			Scribe.i8, Scribe.u8:
				scrf_handle.store_8(scrf_curr_chunk_path[key])
			Scribe.i16, Scribe.u16:
				scrf_handle.store_16(scrf_curr_chunk_path[key])
			Scribe.i32, Scribe.u32:
				scrf_handle.store_32(scrf_curr_chunk_path[key])

			Scribe.ascii:
#				var bytes = 
#				if bytes.length() < format_extra:
#					scrf_handle.store_buffer(bytes)
				scrf_handle.store_buffer(buffer_padded(scrf_curr_chunk_path[key].to_ascii(), format_extra))
			Scribe.utf8:
#				var bytes = scrf_curr_chunk_path[key].to_utf8() # same as store_string()...?
				scrf_handle.store_buffer(buffer_padded(scrf_curr_chunk_path[key].to_utf8(), format_extra))
			Scribe.raw:
				scrf_handle.store_buffer(scrf_curr_chunk_path[key])
	
	return true
