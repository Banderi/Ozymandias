extends Node

onready var ROOT_NODE = get_tree().root.get_node("Root")
onready var MENUS_ROOT = ROOT_NODE.get_node("Menus")

# generics
func is_valid_objref(node):
	if node != null && !(!weakref(node).get_ref()):
		return true
	return false

# MENUS
var debug_last_menu = null
func go_to_menu(menu_name, data = null):
	var menu_node = MENUS_ROOT.get_node_or_null(menu_name)
	if menu_node == null:
		Log.error(self, GlobalScope.Error.ERR_DOES_NOT_EXIST, "menu '%s' is invalid" % [menu_name])
		return
	close_all_menus()
	if menu_node.has_method("_on_menu_open"):
		menu_node._on_menu_open(data)
	debug_last_menu = menu_name
	menu_node.show()
func popup_menu(menu_name, data = null):
	var menu_node = MENUS_ROOT.get_node_or_null(menu_name)
	if menu_node == null:
		Log.error(self, GlobalScope.Error.ERR_DOES_NOT_EXIST, "menu '%s' is invalid" % [menu_name])
		return
	if menu_node.has_method("_on_menu_open"):
		menu_node._on_menu_open(data)
	debug_last_menu = menu_name
	menu_node.show()
func close_all_menus():
	for m in MENUS_ROOT.get_children():
		m.hide()
	debug_last_menu = null

func right_click_pressed(relevant_node, event): # TODO: capture right click when over ANY element of the currently open menu
	if event is InputEventMouseButton && event.button_index == BUTTON_RIGHT:
		return true
	return false

func debug_tools_enabled():
	return false

#############

enum States {
	MainMenu,
	Ingame,
	Paused
}
var STATE = States.MainMenu
func load_game(path):
	if !IO.file_exists(path):
		Log.error(self, GlobalScope.Error.ERR_DOES_NOT_EXIST, "the savefile '%s' does not exist" % [path])
		return false
	else:
		if !Scribe.enscribe(path, File.READ, false, funcref(self, "enscribe_SAV")):
			return false
		
		STATE = States.Ingame
		close_all_menus()
		
		
		return true
func save_game(path):
	if STATE == States.MainMenu:
		Log.error(self, GlobalScope.Error.ERR_LOCKED, "can not save without a game loaded first")
		return false
	else:
#		if !Scribe.enscribe(path, File.WRITE, false, funcref(self, "enscribe_SAV")):
#			return false
#		return true
		print("TODO: saving ------- ", path)

var debug_schema = { # default schema used
	"file_version": 160,
	"chunks_schema": -1,
	"chunks": []
}
func set_schema(): # TODO
	pass
func enscribe_schema():
	Scribe.sync_record([debug_schema], TYPE_DICTIONARY)
	Scribe.put("file_version", ScribeFormat.i32)
	Scribe.put("chunks_schema", ScribeFormat.i32)
	var chunks_beginning = Scribe._handle.get_position()
	for i in range(debug_schema.chunks_schema):
		var s = Scribe._handle.get_position()
		Scribe.sync_record([debug_schema, "chunks", i], TYPE_DICTIONARY)
		Scribe.put("compressed", ScribeFormat.u32)
		Scribe.put("memory_offset", ScribeFormat.u8)
		Scribe.put("memory_location", ScribeFormat.u16)
		Scribe.put("unk03", ScribeFormat.u8)
		Scribe.put("fields_size", ScribeFormat.u32)
		Scribe.put("fields_num", ScribeFormat.u32)
		Scribe.put("unk06", ScribeFormat.u16)
		Scribe.put("unk07", ScribeFormat.u16)
		assert(Scribe._handle.get_position() == s + 20)
		print("%03d: %s %6d %4d : %-6d %-5d %2d : %6d * %5d" % [
			i,
			"(C)" if debug_schema.chunks[i].compressed else "---",
			debug_schema.chunks[i].unk06, debug_schema.chunks[i].unk07,
			debug_schema.chunks[i].memory_location, debug_schema.chunks[i].memory_offset, debug_schema.chunks[i].unk03,
			debug_schema.chunks[i].fields_num, debug_schema.chunks[i].fields_size
		])
	Scribe._handle.seek(chunks_beginning + 300 * 20) # move to the end

func enscribe_SAV():
	Scribe.sync_record([Campaign.data, "headers"], TYPE_DICTIONARY) # TODO: move to "Scenario" singleton
	Scribe.put("map_index", ScribeFormat.u8)
	Scribe.put("campaign_index", ScribeFormat.u8)
	Scribe.put("prev_progress_pointer", ScribeFormat.i8)
	Scribe.put("mission_progress_pointer", ScribeFormat.i8)
	enscribe_schema()
	
#	Scribe.sync_record([Map.grids], TYPE_DICTIONARY)
	Scribe.put_grid("image", true, ScribeFormat.u32)
	Scribe.put_grid("edge", true, ScribeFormat.i8)
	Scribe.put_grid("building", true, ScribeFormat.i16)
	Scribe.put_grid("terrain", true, ScribeFormat.u32)
	Scribe.put_grid("aqueduct", true, ScribeFormat.u8)
	Scribe.put_grid("figure", true, ScribeFormat.u16)
	Scribe.put_grid("bitfields", true, ScribeFormat.u8)
	Scribe.put_grid("sprite", true, ScribeFormat.u8)
	Scribe.put_grid("random", false, ScribeFormat.u8)
	Scribe.put_grid("desirability", true, ScribeFormat.u8)
	Scribe.put_grid("elevation", true, ScribeFormat.u8)
	Scribe.put_grid("building_dmg", true, ScribeFormat.i16)
	Scribe.put_grid("aqueduct_bak", true, ScribeFormat.u8)
	Scribe.put_grid("sprite_bak", true, ScribeFormat.u8)
	
	
#	print(Campaign.map_data)
#	print(debug_schema.file_version)
	
	return true

#func begin_new_campaign():
#	pass

#############

var ticks = 0
func game_loop(delta):
	for i in debug_test_spinbox.value:
		ticks += 1
func game_tick(delta):
	pass

#############

# Called when the node enters the scene tree for the first time.
func _ready():
	debug_test_button.connect("pressed", self, "_on_DebugTestBtn_Pressed")

	Assets.load_locales()
	Assets.load_tilesets()

	
	close_all_menus()
	
	# TODO:
	# loading:
	
	# bink video: intro
	
#	go_to_menu("Splash")
#	go_to_menu("FamilySelection")
	go_to_menu("GameSelection", "Banhutep")
	popup_menu("SavegameSelection", false)
#	go_to_menu("TextureRect2")
#	go_to_menu("Control2")
	
#	Family.JAS_load("D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra/Save/highscore.jas")
#	Family.JAS_save("D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra/Save/highscore2.jas")
	
#	Family.DAT_load("D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra/Save/Banhutep.dat", "Banhutep")
#	Family.DAT_save("D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra/Save/Banhutep2.dat", "Banhutep")


onready var DEBUG_ROOT = ROOT_NODE.get_node("Debug")
onready var debug_label = DEBUG_ROOT.get_node("DEBUG_LABEL")
onready var debug_fps_label = DEBUG_ROOT.get_node("DEBUG_FPS")
onready var debug_test_label = DEBUG_ROOT.get_node("DEBUG_LABEL2")
onready var debug_test_spinbox = debug_test_label.get_node("SpinBox")
onready var debug_test_button = debug_test_label.get_node("Button")

var last_fps = 60
var test_adj = 1
func _on_DebugTestBtn_Pressed():
	ticks = 100
func tick_maxfps_test(delta):
	if (1.0 / delta) < 59.8:
		test_adj = min(test_adj - 10, 0)
	else:
		test_adj = max(test_adj + 1, 0)
	debug_test_spinbox.value += test_adj

# Called every frame. 'delta' is the elapsed time since the previous frame.
var t = 0
func _process(delta):
	t += delta
#	if t > 1:
#		TranslationServer.set_locale("en")
#	if t > 2:
#		t = 0
#		TranslationServer.set_locale("it")

	game_loop(delta)

	# debug prints
	var debug_text = "[color=#888888]Ozymandias Godot3.6 v0.1[/color]\n"
	debug_text += "[color=#888888]game_state:[/color]       %s\n" % [Log.get_enum_string(States, STATE)]
	debug_text += "[color=#888888]last_menu:[/color]        %s\n" % [debug_last_menu]
	debug_text += "[color=#888888]current_family:[/color]   %s\n" % [Family.current_family]
	debug_text += "[color=#888888]families:[/color]         %s\n" % [Family.data.size()]
	
	if debug_label.bbcode_text != debug_text:
		debug_label.bbcode_text = debug_text
	
	last_fps = Engine.get_frames_per_second()
	debug_fps_label.text = str(last_fps, " FPS")
	
	if debug_test_label.visible:
		debug_test_label.text = "%s (%s)\n%s" % [delta, 1.0 / delta, ticks]
		tick_maxfps_test(delta)
