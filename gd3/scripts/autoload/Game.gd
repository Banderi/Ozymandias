extends Node

onready var ROOT_NODE = get_tree().root.get_node("Root")

# generics
func is_valid_objref(node):
	if node != null && !(!weakref(node).get_ref()):
		return true
	return false

# MENUS
func open_menu(menu_name):
	ROOT_NODE.get_node(menu_name).show()
func close_menu(menu_name):
	ROOT_NODE.get_node(menu_name).hide()
func close_all_menus():
	for m in ROOT_NODE.get_children():
		m.hide()

func right_click_pressed(relevant_node, event): # TODO: this doesn't capture perfectly for menus without a stack. ugh.
	if event is InputEventMouseButton && event.button_index == BUTTON_RIGHT:
		return true
	return false

func debug_tools_enabled():
	return false

#############

# Called when the node enters the scene tree for the first time.
func _ready():
	
#	TranslationServer.set_locale("en")
#	TranslationServer.set_locale("it")
	
	
#	var tr = [
#		"res://assets/locales/test_en.en.translation",
#		"res://assets/locales/test_en.it.translation"
#	]
#	ProjectSettings.set_setting("locale/translations", tr)

#	var text_en = Assets.load_lang(Assets.INSTALL_PATH + "/Pharaoh_Text.eng", "en")
#	ResourceSaver.save("res://assets/locales/Pharaoh_Text.en.translation", text_en)
#	IO.write("res://assets/locales/Pharaoh_Text.en.translation", text_en)

#	var text_en = load("res://assets/locales/Pharaoh_Text.en.translation")
#	TranslationServer.add_translation(text_en)
#	TranslationServer.set_locale("en")
	
	var a = TranslationServer.translate("TEXT_30_0")

#	var t = load("E:/Godot/Projects/Ozymandias/gd3/assets/locales/a/test.csv")
#	var t = load("E:/Godot/Projects/Ozymandias/gd3/assets/locales/test_en.it.translation")

#	var a = t.get_message("TEST3")

	
	close_all_menus()
	
	# TODO:
	# loading:
	
	# bink video: intro
	
	open_menu("Splash")
	
#	Family.JAS_load("D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra/Save/highscore.jas")
#	Family.JAS_save("D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra/Save/highscore2.jas")
	
#	Family.DAT_load("D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra/Save/Banhutep.dat", "Banhutep")
#	Family.DAT_save("D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra/Save/Banhutep2.dat", "Banhutep")


# Called every frame. 'delta' is the elapsed time since the previous frame.
var t = 0
func _process(delta):
	t += delta
#	if t > 1:
#		TranslationServer.set_locale("en")
#	if t > 2:
#		t = 0
#		TranslationServer.set_locale("it")
		
