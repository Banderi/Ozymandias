extends Node

# generics
func MAX(bs):
	return (1 << bs)
func u_to_i(unsigned, bs):
	return (unsigned + MAX(bs-1)) % MAX(bs) - MAX(bs-1)
func buffer_padded(arr: PoolByteArray, size):
	var s = size - arr.size()
	if s > 0:
		var t = PoolByteArray()
		t.resize(s)
		t.fill(0)
		arr.append_array(t)
	return arr

# SCRIBE
var _path = null
var _handle: File = null
var _filesize = null
var _flags = null
func bail(err, msg) -> bool:
	Log.error(self, err, msg)
	close()
	assert(false)
	return false
func open(flags, path, offset = 0):
	_handle = File.new()
	var r = _handle.open(path, flags)
	if r != OK:
		return bail(r, str("could not open file handle '",path,"'"))
	_flags = flags
	_filesize = _handle.get_len()
	Log.generic("Scribe", "opening \"%s\" (%s bytes)" % [path, _filesize])
	var _r = goto_offset(offset)
	return true
func goto_offset(offset) -> bool:
	if offset < 0 || offset > _filesize:
		return false
	_handle.seek(offset)
	return true
func close():
	if _handle != null:
		_handle.close()
	_handle = null
	_path = null
	_filesize = null
	_flags = null
	_curr_record_ref = null
	
var _curr_record_ref = null
func sync_record(chunk_path: Array, leaf_type) -> bool:
	if chunk_path.size() < 1:
		return bail(GlobalScope.Error.ERR_INVALID_PARAMETER, "the supplied path is empty")
	
	# reset chunk ref
	_curr_record_ref = null
	
	
	# root -- this MUST be a reference-able object (dict or array)
	var root = chunk_path[0]
	if !(root is Dictionary || root is Array):
		return bail(GlobalScope.Error.ERR_INVALID_PARAMETER, "the supplied root is invalid (%s)" % [root])
	_curr_record_ref = root
	
	# traverse the rest of the path / tree
	for i in range(1, chunk_path.size()):
		var key = chunk_path[i]
		
		# node is describing an array element
		if key is int:
			if !(_curr_record_ref is Array):
				return bail(GlobalScope.Error.ERR_INVALID_PARAMETER, "the key '%s' requires a parent of type Array" % [key])
			if _curr_record_ref.size() < key + 1:
				
				if i < chunk_path.size() - 1:
					match typeof(chunk_path[i + 1]):
						TYPE_STRING:
							_curr_record_ref.push_back({})
						TYPE_INT:
							_curr_record_ref.push_back([])
						_:
							return bail(GlobalScope.Error.ERR_INVALID_PARAMETER, "the key '%s' is describing a disallowed type (%s)" % [chunk_path[i + 1], typeof(chunk_path[i + 1])])
				else:
					match leaf_type:
						TYPE_DICTIONARY:
							_curr_record_ref.push_back({})
						TYPE_ARRAY:
							_curr_record_ref.push_back([])
						_:
							return bail(GlobalScope.Error.ERR_INVALID_PARAMETER, "the leaf type '%s' is not allowed" % [leaf_type])
		
		# node is describint a dictionary element
		elif key is String:
			if !(_curr_record_ref is Dictionary):
				return bail(GlobalScope.Error.ERR_INVALID_PARAMETER, "the key '%s' requires a parent of type Dictionary" % [key])
			
			if !_curr_record_ref.has(key):
				
				if i < chunk_path.size() - 1:
					match typeof(chunk_path[i + 1]):
						TYPE_STRING:
							_curr_record_ref[key] = {}
						TYPE_INT:
							_curr_record_ref[key] = []
						_:
							return bail(GlobalScope.Error.ERR_INVALID_PARAMETER, "the key '%s' is describing a disallowed type (%s)" % [chunk_path[i + 1], typeof(chunk_path[i + 1])])
				else:
					match leaf_type:
						TYPE_DICTIONARY:
							_curr_record_ref[key] = {}
						TYPE_ARRAY:
							_curr_record_ref[key] = []
						_:
							return bail(GlobalScope.Error.ERR_INVALID_PARAMETER, "the leaf type '%s' is not allowed" % [leaf_type])
			
		# move the leaf ref along
		_curr_record_ref = _curr_record_ref[key]
	
	return true

# compressed (zip) ops and data chunks I/O helpers
var _compressed_stack = []
var _compressed_ptr = null
func zip_uncompress(data: PoolByteArray) -> PoolByteArray:
	return data
func zip_compress(data: PoolByteArray) -> PoolByteArray:
	return data
func push_compressed() -> bool:
	if _handle == null:
		return bail(GlobalScope.Error.ERR_LOCKED, "no valid file handle initialized (%s)" % [_handle])
	
	# initialize byte field buffer (empty if writing)
	if _flags == File.READ:
		var o = _handle.get_position()
		var s = _handle.get_32()
		var raw = _handle.get_buffer(s)
		var uncompressed = zip_uncompress(raw)
		_compressed_stack.push_back(uncompressed)
	else:
		_compressed_stack.push_back([] as PoolByteArray)
	_compressed_ptr = _compressed_stack[-1]
	
	return true
func pop_compressed() -> bool: # TODO
	if _handle == null:
		return bail(GlobalScope.Error.ERR_LOCKED, "no valid file handle initialized (%s)" % [_handle])

	
	var bytes = _compressed_stack.pop_back()
#	put()
#	if _compressed_ptr == null:
#		return bail(GlobalScope.Error.ERR_INVALID_DATA, "tried to ")
#	var compressed = zip_compress(raw)


	
	if _compressed_stack.size() > 0:
		_compressed_ptr = _compressed_stack[-1]
	else:
		_compressed_ptr = null
	return true

# helper I/O for grids (encapsulates push/pop_compressed and put ops)
func put_grid(key, format, compressed: bool, grid_size: int = Map.PH_MAP_SIZE, default = 0) -> bool:
	if !push_compressed():
		return false
	
	# TODO put (each tile) --> key
	
	return true

# primary I/O
func put(key, format, format_extra = null, default = 0) -> bool:
	if _handle == null:
		return bail(GlobalScope.Error.ERR_LOCKED, "no valid file handle initialized (%s)" % [_handle])
	
	if _curr_record_ref == null || !(_curr_record_ref is Dictionary || _curr_record_ref is Array):
		return bail(GlobalScope.Error.ERR_INVALID_DATA, "the last synced chunk is invalid (%s)" % [_curr_record_ref])
	if _curr_record_ref is Dictionary:
		if !(key is String):
			return bail(GlobalScope.Error.ERR_INVALID_PARAMETER, "the parent chunk (Dictionary) requires a key of type String")
		if !_curr_record_ref.has(key):
			_curr_record_ref[key] = default
	if _curr_record_ref is Array:
		if !(key is int):
			return bail(GlobalScope.Error.ERR_INVALID_PARAMETER, "the parent chunk (Array) requires a key of type Int")
		if _curr_record_ref.size() <= key:
			_curr_record_ref.push_back(default)
	
	if _flags == File.READ:
		if _handle.eof_reached() || _handle.get_position() >= _handle.get_len():
			return bail(GlobalScope.Error.ERR_FILE_EOF, "file end reached")
		match format: # Godot File ops, by default, are UNSIGNED
			ScribeFormat.i8:
				_curr_record_ref[key] = u_to_i(_handle.get_8(), 8)
			ScribeFormat.u8:
				_curr_record_ref[key] = _handle.get_8()
			ScribeFormat.i16:
				_curr_record_ref[key] = u_to_i(_handle.get_16(), 16)
			ScribeFormat.u16:
				_curr_record_ref[key] = _handle.get_16()
			ScribeFormat.i32:
				_curr_record_ref[key] = u_to_i(_handle.get_32(), 32)
			ScribeFormat.u32:
				_curr_record_ref[key] = _handle.get_32()
			
			# BUG / DISCREPANCY: these will read as null-terminated, thus rewrites are NOT byte-matching past valid text data
			ScribeFormat.ascii:
				_curr_record_ref[key] = _handle.get_buffer(format_extra).get_string_from_ascii()
			ScribeFormat.utf8:
				_curr_record_ref[key] = _handle.get_buffer(format_extra).get_string_from_utf8()
			ScribeFormat.raw:
				_curr_record_ref[key] = _handle.get_buffer(format_extra)
	else:
		match format:
			# these do not have an unsigned version (TODO?)
			ScribeFormat.i8, ScribeFormat.u8:
				_handle.store_8(_curr_record_ref[key])
			ScribeFormat.i16, ScribeFormat.u16:
				_handle.store_16(_curr_record_ref[key])
			ScribeFormat.i32, ScribeFormat.u32:
				_handle.store_32(_curr_record_ref[key])

			ScribeFormat.ascii:
				_handle.store_buffer(buffer_padded(_curr_record_ref[key].to_ascii(), format_extra))
			ScribeFormat.utf8:
				_handle.store_buffer(buffer_padded(_curr_record_ref[key].to_utf8(), format_extra)) # same as store_string()...?
			ScribeFormat.raw:
				_handle.store_buffer(_curr_record_ref[key])
	
	return true

func enscribe(path, operation, create_backup, enscriber_proc: FuncRef, enscriber_args: Array = []):
	if create_backup && operation != File.READ && IO.file_exists(path) && !IO.copy_file(path, path + ".bak", true):
		return false
	
	if !Scribe.open(operation, path):
		return false
	
	var t = Stopwatch.start()
	var r = enscriber_proc.call_funcv(enscriber_args)
	r = _handle == null
	Scribe.close()
	Stopwatch.stop(self, t, "time taken:")
	return r
