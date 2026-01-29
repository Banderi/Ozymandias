extends Node

# settings -- these are automatically iterated over, loaded and saved!
# DO NOT ADD VARS TO THIS SCRIPT WHICH YOU DO NOT INTEND TO WRITE TO SETTING FILES.
# var setting1 = value
# var setting2 = value
# var setting3 = value

var custom_keybinds = {}

func settings_list():
	return get_script().get_script_property_list()

# settings IO
const DATA_PATH = "user://data.json"
func save_user_data(export_file_path = ""):
	var settings = {}
	for property in settings_list():
		var variable = property.name
		settings[variable] = get(variable)

	IO.write(export_file_path if export_file_path != "" else DATA_PATH, to_json(settings))
func load_user_data(import_file_path = ""):
	var fdata = IO.read(import_file_path if import_file_path != "" else DATA_PATH, true)
	if fdata != null:
		var data = parse_json(fdata)
		for variable in data:
			set(variable, data[variable])

		# HERE: refresh/reload settings in the game
	elif import_file_path == "":
		Log.generic(null,str("No user data file found, creating a new one..."))
		save_user_data()
func update(variable, value, force = false):
	if variable in self && (force || get(variable) != value):
		set(variable, value)
		save_user_data()
func update_dictionary(dictionary, key, value, force = false):
	if dictionary in self && (!get(dictionary).has(key) || force || get(dictionary).get(key) != value):
			get(dictionary)[key] = (value)
			save_user_data()
func clear_dictionary(dictionary, key = null):
	if dictionary in self:
		if key == null:
			get(dictionary).clear()
		elif key in get(dictionary):
			get(dictionary).erase(key)
		save_user_data()
