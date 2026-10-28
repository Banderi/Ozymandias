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
func bail(err, msg) -> bool:
	Log.error(self, err, msg)
	close()
	assert(false)
	return false
func open(flags, path, offset = 0):
	return ScribeMono.openFile(flags, IO.get_abs_path(path), offset)
func close():
	return ScribeMono.closeFile()
func assert_eof():
	return ScribeMono.AssertEOF()

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
	
	# Mono
	ScribeMono._curr_record_ref = _curr_record_ref
	return true

## compressed chunk stack ops and I/O helpers
func push_compressed(expected_size: int) -> bool: # new bytestream buffer (empty on WRITE, decompress from file handle on READ)
	return ScribeMono.PushCompressed(expected_size)
func pop_compressed() -> bool: # compress and write top bytestream to file on WRITE, or discard on READ
	return ScribeMono.PopCompressed()

## helper I/O for grids (encapsulates push/pop_compressed and put ops)
func put_grid(format, grid_name: String, compressed: bool, grid_width: int = Map.PH_MAP_WIDTH, default = 0) -> bool:
	var _t = Stopwatch.start()
	if !ScribeMono.PutGrid(format, grid_name, compressed, grid_width):
		return false
	print("grid %-20s ms taken: %3d %s" % [
		"'" + grid_name + "'",
		Stopwatch.query(_t),
		"" if compressed else ">> not compressed <<"
	])
	return true

# primary I/O
func put(format, key, format_extra = null, default = 0) -> bool:
	return ScribeMono.put(format, key, format_extra) # ~1350-1500
func skip(n):
	return ScribeMono.Skip(n);

func enscribe(path, operation, create_backup, enscriber_proc: FuncRef, enscriber_args: Array = []):
	if create_backup && operation != File.READ && IO.file_exists(path) && !IO.copy_file(path, path + ".bak", true):
		return false
	
	if !Scribe.open(operation, path):
		return false
	
	var t = Stopwatch.start()
	var r = enscriber_proc.call_funcv(enscriber_args)
	Scribe.close()
	Stopwatch.stop(self, t, path)
	return r
