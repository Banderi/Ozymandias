extends Node

onready var ROOT_NODE = get_tree().root.get_node("Root")
var OVERSEERS_ROOT = null

func open():
	if OVERSEERS_ROOT == null: # TODO: a better way for this...
		OVERSEERS_ROOT = ROOT_NODE.get_node("Menus/Overseers")
	Game.popup_menu("Overseers")
func close():
	Game.close_menu("Overseers")
#	Game.close_all_menus()
#	Game.STATE = Game.States.Ingame

#var current_tab_node = null
func select(tab): # TODO: select last selected on map loading (default = granaries)
#	var n = OVERSEERS_ROOT.get_node_or_null(tab)
#	if n == null:
#		Log.error(self, ERR_DOES_NOT_EXIST, "overseer tab '%s' is invalid" % [tab])
#		return false
	OVERSEERS_ROOT.select_tab(tab)
#	OVERSEERS_ROOT.release_buttons()
#
#	if current_tab_node != null:
#		current_tab_node.hide()
#	n.show()
#	current_tab_node = n
