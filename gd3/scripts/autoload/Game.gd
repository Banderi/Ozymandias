extends Node

onready var ROOT_NODE = get_tree().root.get_node("Root")

# generics
func is_valid_objref(node):
	if node != null && !(!weakref(node).get_ref()):
		return true
	return false

## MENUS
# I'm differentiating between menus and popups (for now) such that menus close all others menus first, popups don't.
# this is because all the UI nodes are in a fixed order in the scene, so would hide each other
var debug_last_menu = null
#var debug_last_popup = null
func go_to_menu(menu_name, data = null):
	var menu_node = ROOT_NODE.get_node_or_null(menu_name)
	if menu_node == null:
		Log.error(self, GlobalScope.Error.ERR_DOES_NOT_EXIST, "menu '%s' is invalid" % [menu_name])
		return
	close_all_menus()
	if menu_node.has_method("_on_menu_open"):
		menu_node._on_menu_open(data)
	debug_last_menu = menu_name
	menu_node.show()
#	return popup_menu(menu_name, data)
func popup_menu(menu_name, data = null):
	var menu_node = ROOT_NODE.get_node_or_null(menu_name)
	if menu_node == null:
		Log.error(self, GlobalScope.Error.ERR_DOES_NOT_EXIST, "menu '%s' is invalid" % [menu_name])
		return
#	close_all_menus()
	if menu_node.has_method("_on_menu_open"):
		menu_node._on_menu_open(data)
	debug_last_menu = menu_name
	menu_node.show()
#func open_popup(popup_name, data = null):
#	var popup_node = ROOT_NODE.get_node_or_null(popup_name)
#	if popup_node == null:
#		Log.error(self, GlobalScope.Error.ERR_DOES_NOT_EXIST, "popup '%s' is invalid" % [popup_name])
#		return
#	if popup_node.has_method("_on_popup_open"):
#		popup_node._on_popup_open(data)
#	debug_last_popup = popup_name
#	popup_node.show()
func close_all_menus():
	for m in ROOT_NODE.get_children():
		m.hide()
	debug_last_menu = null
#	debug_last_popup = null

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
	pass
func save_game(path):
	if STATE == States.MainMenu:
		return false
	else:
		pass

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

	
	close_all_menus()
	
	# TODO:
	# loading:
	
	# bink video: intro
	
#	go_to_menu("Splash")
#	go_to_menu("FamilySelection")
	go_to_menu("GameSelection", "Banhutep")
#	go_to_menu("SavegameSelection")
#	go_to_menu("TextureRect2")
#	go_to_menu("Control2")
	
#	Family.JAS_load("D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra/Save/highscore.jas")
#	Family.JAS_save("D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra/Save/highscore2.jas")
	
#	Family.DAT_load("D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra/Save/Banhutep.dat", "Banhutep")
#	Family.DAT_save("D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra/Save/Banhutep2.dat", "Banhutep")


onready var debug_label = ROOT_NODE.get_node("CanvasLayer/DEBUG_LABEL")
onready var debug_fps_label = ROOT_NODE.get_node("CanvasLayer/DEBUG_FPS")
onready var debug_test_label = ROOT_NODE.get_node("CanvasLayer/DEBUG_LABEL2")
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
#	debug_text += "[color=#888888]last_popup:[/color]       %s\n" % [debug_last_popup]
	debug_text += "[color=#888888]current_family:[/color]   %s\n" % [Family.current_family]
	debug_text += "[color=#888888]families:[/color]         %s\n" % [Family.families_data.size()]
	
	if debug_label.bbcode_text != debug_text:
		debug_label.bbcode_text = debug_text
	
	last_fps = Engine.get_frames_per_second()
	debug_fps_label.text = str(last_fps, " FPS")
	
	if debug_test_label.visible:
		debug_test_label.text = "%s (%s)\n%s" % [delta, 1.0 / delta, ticks]
		tick_maxfps_test(delta)
