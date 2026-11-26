extends Node


onready var ROOT_NODE = get_tree().root.get_node("Root")
#onready var OVERSEERS_ROOT = ROOT_NODE.get_node("Menus/Overseers")

func open():
	Game.popup_menu("Overseers")
func close():
	Game.close_menu("Overseers")
#	Game.close_all_menus()
#	Game.STATE = Game.States.Ingame
