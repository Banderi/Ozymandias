extends Node
# ANTIMONY 'IO' by Banderi --- v1.3

# check if running via Godot editor Play/F5 function (NOT in-editor "tool" scripts)
func is_editor():
	var exe_filename = naked_filename(OS.get_executable_path())
	return "Godot" in exe_filename

# directory IO
func get_runtime_path(trail_slash = true):
	return naked_folder_path(OS.get_executable_path(), trail_slash)
func get_folder_split_path(path):
	# this only legally accepts full paths with a file name at the end!
	var result = path.rsplit('/', false, 1)
	if result.size() == 1:
		return ["", result[0]]
	result[0] += '/'
	return result
func naked_folder_path(path, trail_slash = true):
	var lsl_idx = path.find_last('/')
	if lsl_idx == -1:
		return path + ('/' if trail_slash else '')
	else:
		return path.substr(0, lsl_idx + (1 if trail_slash else 0))
func naked_filename(path):
	var lsl_idx = path.find_last('/')
	if lsl_idx == -1:
		return path # different behavior than naked_folder_path -- here we assume it's a trailing name, not a drive name
	else:
		var file_name = path.substr(lsl_idx + 1)
		return null if file_name == "" else file_name

# basic IO
func write(path, data, create_folder_if_missing = true, password = ""):
	var err = -1

	# check path
	var split_path = get_folder_split_path(path)
	var dir = Directory.new()
	if !dir.dir_exists(split_path[0]):
		if create_folder_if_missing:
			err = dir.make_dir_recursive(split_path[0])
			if err != OK:
				Log.error(null,err,str("could not create directory at '",split_path[0],"' for file '",split_path[1],"'"))
				return false
		else:
			Log.error(null,7,str("directory '",split_path[0],"' not found for file '",split_path[1],"'"))
			return false
#	if data is Resource:
#		err = ResourceSaver.save(path, data)
#		if err != OK:
#			Log.error(null,err,str("could not write to file '",path,"'"))
#			return false
#		Log.generic(null,str("file '",path,"' written successfully!"))
#		return true
#	else:

	# init stream
	var file = File.new()
	if password == "":
		err = file.open(path, File.WRITE)
	else:
		err = file.open_encrypted_with_pass(path, File.WRITE, password)
	if err != OK:
		Log.error(null,err,str("could not write to file '",path,"'"))
		return false

	# write data
	if data is String:
		file.store_string(data)
	else:
		file.store_var(data, true)

	# close stream
	file.close()
	Log.generic(null,str("file '",path,"' written successfully!"))
	return true
func read(path, get_as_text = false, password = ""):
	# init stream
	var file = File.new()
	var err = -1
	if password == "":
		err = file.open(path, File.READ)
	else:
		err = file.open_encrypted_with_pass(path, File.READ, password)
	if err != OK:
		Log.error(null,err,str("could not read file '",path,"'"))
		return null

	# read data
	var data = null
	if get_as_text:
		data = file.get_as_text()
	else:
		data = file.get_var(true)
#		data = str2var(file.get_as_text())

	# close stream
	file.close()
	Log.generic(null,str("file '",path,"' read successfully!"))
	return data
func file_exists(path):
	var file = File.new()
	return file.file_exists(path)
func metadata(path):
	var file = File.new()
	var err = file.open(path, File.READ)
	if err != OK:
		Log.error(null,err,str("could not read file '",path,"'"))
		return null
	var data = {
		"extension": path.get_extension(),
		"modified_timestamp": file.get_modified_time(path),
		"modified_datetime": OS.get_datetime_from_unix_time(file.get_modified_time(path)),
		"md5": file.get_md5(path),
		"length": file.get_len(),
	}
	file.close()
	return data
func delete(path):
	var dir = Directory.new()
	var err = dir.remove(path)
	if err != OK:
		Log.error(null,err,str("could not delete file '",path,"'"))
		return false
	return true
func rename(path, new_filename):
	var dir = Directory.new()
	var err = dir.rename(path, new_filename)
	if err != OK:
		Log.error(null,err,str("could not rename file '",path,"' to '",new_filename,"'"))
		return false
	return true
func move_file(path, to, remove_previous = true, overwrite = false):
	if !overwrite && file_exists(to):
		Log.error(null,GlobalScope.Error.ERR_ALREADY_EXISTS,str("could not move file from '",path,"' to '",to,"'"))
		return false
	var dir = Directory.new()
	var err = dir.copy(path, to)
	if err != OK:
		Log.error(null,err,str("could not move file from '",path,"' to '",to,"'"))
		return false
	if remove_previous:
		err = dir.remove(path)
		if err != OK:
			Log.error(null,err,str("could not delete file '",path,"'"))
			return false
	return true
func copy_file(path, to, overwrite = false):
	return move_file(path, to, false, overwrite)

func dir_contents(path, filter_by = ""):
	var dir = Directory.new()
	var err = dir.open(path)
	if err != OK:
		Log.error(null,err,str("could not access directory '",path,"'"))
		return null
	else:
		var results = {
			"folders":{},
			"files":{}
		}
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name != "." && file_name != ".." :
				if filter_by == "" || file_name.find(filter_by) != -1:
					var file_data = metadata(str(path,"/",file_name))
					if dir.current_is_dir():
						results.folders[file_name] = file_data
					else:
						results.files[file_name] = file_data
			file_name = dir.get_next()
		return results
func find_most_recent_file(path):
	var results = dir_contents(path)

	var most_recent_timestamp = -1
	var most_recent_file = null
	for file_name in results.files:
		var file = results.files[file_name]
		if file.modified_timestamp > most_recent_timestamp:
			most_recent_timestamp = file.modified_timestamp
			most_recent_file = file_name
	return most_recent_file

# code by @DanielKotzer https://godotforums.org/d/20958-extracting-the-content-of-a-zip-file/4
func unzip(zip_file, destination):
	# load Gdunzip addon script
	var gdunzip = load("res://addons/gdunzip/gdunzip.gd").new()
	var r = gdunzip.load(zip_file)
	if !r:
		Log.error(null,GlobalScope.Error.ERR_CANT_OPEN,str("could not load zip file '",zip_file,"'"))
		return GlobalScope.Error.ERR_CANT_OPEN

	# read zip file contents and adds them to project's virtual workspace
	r = ProjectSettings.load_resource_pack(zip_file)
	if !r:
		Log.error(null,GlobalScope.Error.ERR_CANT_ACQUIRE_RESOURCE,str("could not load file '",zip_file,"' unzipped contents"))
		return GlobalScope.Error.ERR_CANT_ACQUIRE_RESOURCE

	# extract single files from project workspace and write to disk
	for f in gdunzip.files:
		r = export_virtual_file(f, destination)
		if r != OK:
			return r
	return OK
func export_virtual_file(file_name, destination):
	# open read stream
	var file = File.new()
	if !file.file_exists("res://" + file_name):
		Log.error(null,GlobalScope.Error.ERR_FILE_NOT_FOUND,str("could not find virtual file '",file_name,"'"))
		return GlobalScope.Error.ERR_FILE_NOT_FOUND
	else:
		var r = file.open(("res://" + file_name), File.READ)
		if r != OK:
			Log.error(null,r,str("could not open virtual file '",file_name,"'"))
			return r
			
		var content = file.get_buffer(file.get_len())
		file.close()

		# create directory if it doesn't exist
		var base_dir = destination + file_name.get_base_dir()
		var dir = Directory.new()
		r = dir.make_dir(base_dir)
		if r != OK && r != GlobalScope.Error.ERR_ALREADY_EXISTS:
			Log.error(null,r,str("could not create folder at '",base_dir,"' for file '",file_name,"'"))
			return r

		# open write stream
		file = File.new()
		r = file.open(destination + file_name, File.WRITE)
		if r != OK:
			Log.error(null,r,str("could not create file at '",destination + file_name,"'"))
			return r
		file.store_buffer(content)
		file.close()
		
		return OK
