extends Node

func validate_mapping(mapping):
	if !(mapping is Dictionary):
		return false
	if !mapping.has("value") || !mapping.has("type"):
		return false
	# TODO: validate type/value...
	return true
func extract_mapping(event):
	if event == null:
		return null
	var type = event.get_class()
	match type:
		"InputEventJoypadButton":
			return {
				"type": "joypad",
				"value": event.button_index
			}
		"InputEventMouseButton":
			return {
				"type": "mousebutton",
				"value": event.button_index
			}
		"InputEventKey":
			return {
				"type": "key",
				"value": event.scancode
			}
	return null
func construct_event(mapping):
	if !validate_mapping(mapping):
		return null
	var event = null
	match mapping.type:
		"joypad":
			event = InputEventJoypadButton.new()
			event.set_button_index(mapping.value)
		"mousebutton":
			event = InputEventMouseButton.new()
			event.set_button_index(mapping.value)
		"key":
			event = InputEventKey.new()
			event.set_scancode(mapping.value)
	return event

func reload_from_settings(action):
	# get from settings, so we don't overdelete
	# AND so we only check once! :)
	var mappings = get_from_settings(action)
	for m in mappings:
		var event = construct_event(m)
		event_erase(action, event, false)
		event_change(action, event, false)
func get_from_settings(action):
	var mappings = null
	if Settings.custom_keybinds.has(action):
		mappings = Settings.custom_keybinds[action]
	if mappings != null:
		for m in mappings:
			if !validate_mapping(m):
				Log.error(null, GlobalScope.Error.ERR_INVALID_DATA, "Keybind mappings in storage are invalid.")
				mappings = null
				break
	if mappings != null:
		return mappings
	return null
func save_to_settings(action):
	Settings.update_dictionary("custom_keybinds", action, get_mappings(action, null, false))
func destroy_settings(action):
	var default_events = get_events(action, false, true)
	var curr_events = get_events(action, false, false)
	for e in curr_events:
		event_erase(action, e, false)
	for e in default_events:
		event_add(action, e, false)
	save_to_settings(action)

func get_events(action, check_settings, default):
	var events = []
	if default || Engine.editor_hint: # for "tool" scripts (in-editor updates)
		var action_setting_path = str("input/" + action)
		if !ProjectSettings.has_setting(action_setting_path):
			return null
		var input_event_dat = ProjectSettings.get_setting(action_setting_path)
		if input_event_dat == null || !input_event_dat.has("events"):
			return null
		else:
			events = input_event_dat.events
	else: # for normal game

		# first, check custom keybinds from user data
		if check_settings:
			var mappings = get_from_settings(action)
			if mappings != null:
				for m in mappings:
					events.push_back(construct_event(m))

		# else, get from project settings
		events = InputMap.get_action_list(action)
	return events
func get_mappings(action, type = null, check_settings = true):
	var mappings = null
	# first, check custom keybinds from user data
	if check_settings:
		mappings = get_from_settings(action)
		if mappings != null:
			return mappings

	# else, construct from project settings
	var events = get_events(action, false, false)
	if events == null:
		return null
	mappings = []
	for e in events:
		if type == null || e is type:
			mappings.push_back(extract_mapping(e))
	return mappings

func event_change(action, event, save = true): # if only one-per-type is allowed
	for e in get_events(action, true, false):
		if e.get_class() == event.get_class():
			event_erase(action, e, false)
	InputMap.action_add_event(action, event)
	if save:
		save_to_settings(action)
func event_add(action, event, save = true): # if multiple ones are allowed
	if !InputMap.action_has_event(action, event):
		InputMap.action_add_event(action, event)
	if save:
		save_to_settings(action)
func event_erase(action, event, save = true):
	InputMap.action_erase_event(action, event)
	if save:
		save_to_settings(action)
