extends Node

# generics
func MAX(bs):
	return (1 << bs)
func u_to_i_inefficient(unsigned, bs):
	return (unsigned + MAX(bs-1)) % MAX(bs) - MAX(bs-1)
func buffer_padded(arr: PoolByteArray, size):
	var s = size - arr.size()
	if s > 0:
		var t = PoolByteArray()
		t.resize(s)
		t.fill(0)
		arr.append_array(t)
	return arr
func format_size(format):
	match format:
		ScribeFormat.u8, ScribeFormat.i8:
			return 1
		ScribeFormat.u16, ScribeFormat.i16:
			return 2
		ScribeFormat.u32, ScribeFormat.i32:
			return 4
		_: # other formats have UNSPECIFIED sizes
			return null

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
	stop_stopwatch()
	if _handle != null:
		_handle.close()
	_handle = null
	_path = null
	_filesize = null
	_flags = null
	_curr_record_ref = null
func assert_eof():
	if _handle.get_position() != _handle.get_len():
		return bail(GlobalScope.Error.ERR_FILE_EOF, "EOF mismatch")
	return true

# stopwatch used for debugging
var _debug_t = null
const MSEC_60FPS = 1000.0 / 60.0
func debug_stopwatch():
	if _debug_t == null:
		_debug_t = Stopwatch.start()
		return false
	else:
		var t = Stopwatch.query(_debug_t, Stopwatch.Milliseconds)
		return t >= MSEC_60FPS
func stop_stopwatch():
	_debug_t = null

# chunk data reference used for storing / retrieving via put()
var _curr_record_ref = null
func sync_record(chunk_path: Array, leaf_type) -> bool:
	if chunk_path.size() < 1:
		return bail(GlobalScope.Error.ERR_INVALID_PARAMETER, "the supplied path is empty")
	
	# reset chunk ref
	_curr_record_ref = null
	
	
	# root -- this MUST be a reference-able object (dict or array)
	var root = chunk_path[0]
	if !(root is Dictionary || root is Array || root is Node):
		return bail(GlobalScope.Error.ERR_INVALID_PARAMETER, "the supplied root is invalid (%s)" % [root])
	_curr_record_ref = root
	
	# traverse the rest of the path / tree
	for i in range(1, chunk_path.size()):
		var key = chunk_path[i]
		
		# node is describing an array element -- parent MUST be an array type.
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
		
		# node is describint a dictionary element -- parent MUST be a dictionary or a node.
		elif key is String:
			
			if _curr_record_ref is Dictionary:
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
			elif _curr_record_ref is Node:
				if !(key in _curr_record_ref):
					return bail(GlobalScope.Error.ERR_INVALID_PARAMETER, "the key '%s' is not a member of %s" % [key, _curr_record_ref])
			else:
				return bail(GlobalScope.Error.ERR_INVALID_PARAMETER, "the key '%s' requires a parent of type Dictionary or Node" % [key])
			
			
			
			
			
		# move the leaf ref along
		_curr_record_ref = _curr_record_ref[key]
	
	return true

#var __i = 0

# compressed chunk stack ops and I/O helpers
var _compressed_stack = []
var _compressed_top = null
var _compressed_ptr = null
func push_compressed(expected_size) -> bool: # new bytestream buffer (empty on WRITE, decompress from file handle on READ)
	if _flags == File.READ:
		var c_size = _handle.get_32()
		if c_size == 0x80000000:
			var raw = _handle.get_buffer(expected_size)
			_compressed_stack.push_back(raw)
		else:
			var raw = _handle.get_buffer(c_size)
			
#			var fp = IO.open("G:/tests2/"+str(__i), File.WRITE) as File
#			fp.store_buffer(raw)
#			__i += 1
			
			var uncompressed = PKWareMono.Inflate(raw, expected_size)
			if uncompressed == null || uncompressed.size() != expected_size:
				return bail(GlobalScope.Error.ERR_SCRIPT_FAILED, "PKWare decompression failed")
			_compressed_stack.push_back(uncompressed)
	else:
		_compressed_stack.push_back([] as PoolByteArray)
	# -------------- stack pointers
	_compressed_top = _compressed_stack[-1]
	_compressed_ptr = 0
	return true
func pop_compressed() -> bool: # compress and write top bytestream to file on WRITE, or discard on READ
	var bytes = _compressed_stack.pop_back()
	if _flags == File.WRITE:
		var compressed = PKWareMono.Deflate(bytes, 4096)
		if compressed == null:
			return bail(GlobalScope.Error.ERR_SCRIPT_FAILED, "PKWare compression failed")
		_handle.store_32(compressed.size())
		_handle.store_buffer(compressed)
	# -------------- stack pointers
	if _compressed_stack.size() > 0:
		_compressed_top = _compressed_stack[-1]
		_compressed_ptr = 0
	else:
		_compressed_top = null
		_compressed_ptr = null
	return true

# helper I/O for grids (encapsulates push/pop_compressed and put ops)
func put_grid(key, compressed: bool, format, grid_width: int = Map.PH_MAP_WIDTH, default = 0) -> bool:
	var _t = Stopwatch.start()
	var grid_size = grid_width * grid_width
	var raw_size = grid_size * format_size(format)
	if compressed && !push_compressed(raw_size):
		return false # the above already bails on fail
	var _t_1 = Stopwatch.query(_t, Stopwatch.Milliseconds)
	# expected: between 30-60 (smaller ones) and ~140-240 (larger ones)
	
	if _flags == File.READ:
		var stream = null
		if compressed:
			stream = _compressed_top
		else:
			stream = _handle.get_buffer(raw_size)
		GridsMono.SetGrid(Map.grids[key], stream, format)
	else:
		if compressed:
			pass
		else:
			pass
	
#	if _flags == File.READ:
#		if compressed:
#			var stream = StreamPeerBuffer.new()
#			stream.data_array = _compressed_top
#			match format:
#				ScribeFormat.i8:
#					for y in range(grid_width):
#						for x in range(grid_width):
#							Map.set_grid(key, x, y, (stream.get_8() + 128) % 256 - 128)
#				ScribeFormat.u8:
#					for y in range(grid_width):
#						for x in range(grid_width):
#							Map.set_grid(key, x, y, stream.get_8())
#				ScribeFormat.i16:
#					for y in range(grid_width):
#						for x in range(grid_width):
#							Map.set_grid(key, x, y, (stream.get_16() + 256) % 512 - 256)
#				ScribeFormat.u16:
#					for y in range(grid_width):
#						for x in range(grid_width):
#							Map.set_grid(key, x, y, stream.get_16())
#				ScribeFormat.i32:
#					for y in range(grid_width):
#						for x in range(grid_width):
#							Map.set_grid(key, x, y, (stream.get_32() + 512) % 1024 - 512)
#				ScribeFormat.u32:
#					for y in range(grid_width):
#						for x in range(grid_width):
#							Map.set_grid(key, x, y, stream.get_32())
#		else:
#			var tsize = format_size(format)
#			for y in range(grid_width):
#				for x in range(grid_width):
#					_handle.get_buffer(tsize)
#	else:
#		if compressed:
##			for y in range(grid_width):
##				for x in range(grid_width):
#			pass # TODO
#		else:
##			for y in range(grid_width):
##				for x in range(grid_width):
#			pass # TODO
	
	var _t_2 = Stopwatch.query(_t, Stopwatch.Milliseconds)
	# expected: ~10-40 for byte reading, ~10-20 more for Map access, ~30-40 more for TileMap change
	
	if compressed && !pop_compressed():
		return false # the above already bails on fail
	
	var _t_3 = Stopwatch.query(_t, Stopwatch.Milliseconds)
	print("grid %-20s ms taken: %3d %3d (%-3d total) %s" % [
		"'" + key + "'",
		_t_1 + (_t_3 - _t_2),
		_t_2 - _t_1,
		_t_3,
		"" if compressed else ">> not compressed <<"
	])
	return true

# primary I/O
func put(key, format, format_extra = null, default = 0) -> bool:
	if _curr_record_ref == null || !(_curr_record_ref is Dictionary || _curr_record_ref is Array || _curr_record_ref is Node):
		return bail(GlobalScope.Error.ERR_INVALID_DATA, "the last synced chunk is invalid (%s)" % [_curr_record_ref])
	if _curr_record_ref is Dictionary:
		if !(key is String):
			return bail(GlobalScope.Error.ERR_INVALID_PARAMETER, "the parent chunk (Dictionary) requires a key of type String")
		if !_curr_record_ref.has(key):
			_curr_record_ref[key] = default
	elif _curr_record_ref is Node:
		if !(key is String):
			return bail(GlobalScope.Error.ERR_INVALID_PARAMETER, "the parent chunk (Node) requires a key of type String")
		if !(key in _curr_record_ref):
			return bail(GlobalScope.Error.ERR_INVALID_PARAMETER, "the parent chunk (Node) can not introduce new member elements")
	elif _curr_record_ref is Array:
		if !(key is int):
			return bail(GlobalScope.Error.ERR_INVALID_PARAMETER, "the parent chunk (Array) requires a key of type Int")
		if _curr_record_ref.size() <= key:
			_curr_record_ref.push_back(default)
	
	if _compressed_top == null:
		if _flags == File.READ:
			if _handle.eof_reached() || _handle.get_position() >= _handle.get_len():
				return bail(GlobalScope.Error.ERR_FILE_EOF, "file end reached")
			match format: # Godot File ops, by default, are UNSIGNED
				ScribeFormat.i8:
					_curr_record_ref[key] = (_handle.get_8() + 128) % 256 - 128
				ScribeFormat.u8:
					_curr_record_ref[key] = _handle.get_8()
				ScribeFormat.i16:
					_curr_record_ref[key] = (_handle.get_16() + 256) % 512 - 256
				ScribeFormat.u16:
					_curr_record_ref[key] = _handle.get_16()
				ScribeFormat.i32:
					_curr_record_ref[key] = (_handle.get_32() + 512) % 1024 - 512
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
	else:
		print("[Scribe]: tried to '%s' for '%s' bytes (%s)" % [_flags, format_size(format), format])
	
	return true

func enscribe(path, operation, create_backup, enscriber_proc: FuncRef, enscriber_args: Array = []):
	if create_backup && operation != File.READ && IO.file_exists(path) && !IO.copy_file(path, path + ".bak", true):
		return false
	
	if !Scribe.open(operation, path):
		return false
	
	var t = Stopwatch.start()
	var r = enscriber_proc.call_funcv(enscriber_args)
	Scribe.close()
	Stopwatch.stop(self, t, "time taken:")
	return r
