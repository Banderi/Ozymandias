extends Node

onready var ROOT_NODE = get_tree().root.get_node("Root")

# generics
func is_valid_objref(node):
	if node != null && !(!weakref(node).get_ref()):
		return true
	return false

# MENUS
func go_to_menu(menu_name):
	close_all_menus()
	ROOT_NODE.get_node(menu_name).show()
func open_popup(popup_name):
	ROOT_NODE.get_node(popup_name).show()
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
	

	Assets.load_locales()

	
	close_all_menus()
	
	# TODO:
	# loading:
	
	# bink video: intro
	
#	go_to_menu("Splash")
	go_to_menu("NewFamily")
	
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
		
