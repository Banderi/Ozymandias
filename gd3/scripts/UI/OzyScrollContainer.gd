extends Control

export var scroll_node_path : NodePath

# Called when the node enters the scene tree for the first time.
onready var scrollbar = $OzyVScrollBar
var scroll_node = null setget set_scroll_node

#func set_scroll_path(path):
#	scroll_node_path = path
func set_scroll_node(node):
	scroll_node = node
	if scroll_node == null:
		scrollbar.max_value = 0
	else:
		var s_y = scroll_node.get_minimum_size().y
		var p_y = scroll_node.get_parent().rect_size.y
		scrollbar.max_value = max(0, s_y - p_y)

func _ready():
	if scroll_node_path == "":
		return
	set_scroll_node(get_node_or_null(scroll_node_path))
	

func _on_OzyVScrollBar_scrolled(value):
	if scroll_node != null:
		scroll_node.rect_position.y = -value

func _input(event): # redirect scroolwheel inputs to the scrollbar
	if scroll_node == null:
		return
	if event is InputEventMouseButton && event.pressed && scroll_node.get_global_rect().has_point(get_global_mouse_position()):
		match event.button_index:
			BUTTON_WHEEL_UP:
				scrollbar.scroll_delta(-2)
			BUTTON_WHEEL_DOWN:
				scrollbar.scroll_delta(2)
