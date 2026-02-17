extends Control

export var reparent_scroll_node = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var scroll_container = get_parent()
	var panel = scroll_container.get_parent()
	if panel.get_child_count() < 2:
		print(panel, ": no valid scrollable child, skipping")
		return
	var scroll_node = panel.get_child(1)
	yield(panel, "ready") # the childs (self) are ready before the parent, which contains the Scroll Node, so we must wait.
	if reparent_scroll_node:
		panel.remove_child(scroll_node)
		add_child(scroll_node)
	else:
		scroll_node = panel.get_child(1).get_child(0)
	var scroll_node_path = scroll_node.get_path()
	scroll_container.scroll_node_path = scroll_node_path
	scroll_container.set_scroll_node(scroll_node)
	print(panel, ": connected ScrollNodePath to ", scroll_node_path)
