extends Node
# ANTIMONY 'Settings' by Banderi --- v1.2

# vars beginning with an underscore will be ignored.
var _DEFAULTS = {}

# ============================= SETTINGS ============================= #
# settings -- these are automatically iterated over, loaded and saved!
# DO NOT ADD VARS TO THIS SCRIPT WHICH YOU DO NOT INTEND TO WRITE TO SETTING FILES.


var INSTALL_PATH = null





# ==================================================================== #

# settings list / dict operations
func get_settings_list() -> Array: # returns the list of settings from this script.
	var properties = get_script().get_script_property_list()
	var list = []
	for property in properties:
		var variable = property.name
		if !variable.begins_with("_"):
			list.push_back(variable)
	return list
func get_settings() -> Dictionary: # returns the current settings as a dictionary.
	var settings = {}
	for variable in get_settings_list():
		settings[variable] = get(variable)
	return settings
func _ready(): # record the default values.
	for variable in get_settings_list():
		_DEFAULTS[variable] = get(variable)
	reload()
func transpose(_settings, commit_to_disk = true): # this updates the settings from the ones provided in a dictionary.
	for variable in get_settings_list():
		set(variable, _settings[variable])
	if commit_to_disk:
		save()
	# HERE: refresh/reload settings in the game
	return settings_changed_externally()
func reset(commit_to_disk = true):
	return transpose(_DEFAULTS, commit_to_disk)

# settings IO boilerplate
const SETTINGS_PATH = "user://settings.json"
func save(export_file_path = ""):
	IO.write(export_file_path if export_file_path != "" else SETTINGS_PATH, to_json(get_settings()))
func reload(import_file_path = ""):
	var fdata = IO.read(import_file_path if import_file_path != "" else SETTINGS_PATH, true, true)
	if fdata != null:
		var data = parse_json(fdata)
		if data != null:
			for variable in data:
				set(variable, data[variable])

			# HERE: refresh/reload settings in the game
			return settings_changed_externally()
	elif import_file_path == "":
		Log.generic(null,str("No user data file found, creating a new one..."))
		save()

# global callback
func settings_changed_externally():
	pass

# single setting operations
func update(key_path, value, force_commit = false):

	# complex key paths
	if key_path is Array:
		var parent = self
		for key in key_path:
			if parent != self || !(parent is Array) || !(parent is Dictionary):
				Log.error(self, GlobalScope.Error.ERR_INVALID_PARAMETER, "path '%s' is not a valid setting" % [key_path])
			if key in parent:
				if key == key_path[-1]: # reached the final key in the path
					if parent is Array:
						if force_commit || parent[key] != value:
							parent[key] = value
							save()
					else:
						if force_commit || parent.get(key) != value:
							parent.set(key, value)
							save()
				else: # traverse the tree
					if parent is Array:
						parent = parent[key]
					else:
						parent = parent.key
			else:
				return Log.error(self, GlobalScope.Error.ERR_INVALID_PARAMETER, "path '%s' is not a valid setting" % [key_path])
	
	# naked var
	elif key_path is String:
		if key_path in self:
			if force_commit || get(key_path) != value:
				set(key_path, value)
				save()
		else:
			return Log.error(self, GlobalScope.Error.ERR_INVALID_PARAMETER, "key '%s' is not a valid setting" % [key_path])
	else:
		return Log.error(self, GlobalScope.Error.ERR_INVALID_PARAMETER, "key '%s' is not a valid setting" % [key_path])
func clear(key_path, force_commit = false):

	# complex key paths
	if key_path is Array:
		var parent = self
		var parent_DEFAULT = self
		for key in key_path:
			if parent != self || !(parent is Array) || !(parent is Dictionary):
				Log.error(self, GlobalScope.Error.ERR_INVALID_PARAMETER, "path '%s' is not a valid setting" % [key_path])
			if key in parent:
				if key == key_path[-1]: # reached the final key in the path
					
					var value_DEFAULT = parent_DEFAULT[key]
					if parent is Array:
						if force_commit || parent[key] != value_DEFAULT:
							parent_DEFAULT[key] = value_DEFAULT
							save()
					else:
						if force_commit || parent.get(key) != value_DEFAULT:
							parent_DEFAULT.set(key, value_DEFAULT)
							save()
				else: # traverse the tree
					if parent is Array:
						parent = parent[key]
						parent_DEFAULT = parent_DEFAULT[key]
					else:
						parent = parent.key
						parent_DEFAULT = parent_DEFAULT.key
			else:
				return Log.error(self, GlobalScope.Error.ERR_INVALID_PARAMETER, "path '%s' is not a valid setting" % [key_path])
	
	# naked var
	elif key_path is String:
		if key_path in self:
			var value_DEFAULT = _DEFAULTS.get(key_path)
			if force_commit || get(key_path) != value_DEFAULT:
				set(key_path, value_DEFAULT)
				save()
		else:
			return Log.error(self, GlobalScope.Error.ERR_INVALID_PARAMETER, "key '%s' is not a valid setting" % [key_path])
	else:
		return Log.error(self, GlobalScope.Error.ERR_INVALID_PARAMETER, "key '%s' is not a valid setting" % [key_path])
