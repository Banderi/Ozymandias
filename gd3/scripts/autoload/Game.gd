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

func debug_tools_enabled():
	return false

#############

# Called when the node enters the scene tree for the first time.
func _ready():
	close_all_menus()
	open_menu("Splash")
	
	Family.JAS_load("D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra/Save/highscore.jas")
#	Family.JAS_save("D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra/Save/highscore2.jas")
	
	Family.DAT_load("D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra/Save/Banhutep.dat", "Banhutep")
#	Family.DAT_save("D:/SteamLibrary/steamapps/common/Pharaoh + Cleopatra/Save/Banhutep2.dat", "Banhutep")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
