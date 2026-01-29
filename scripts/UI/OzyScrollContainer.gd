extends Control

export var scroll_node_path : NodePath

# Called when the node enters the scene tree for the first time.
onready var scrollbar = $OzyVScrollBar
var scroll_node = null
func _ready():
	pass
#	scroll_node = get_node(scroll_node_path)
#	if scroll_node == null:
#		scrollbar.max_value = 0
#	else:
#		scrollbar.max_value = scroll_node.get_minimum_size().y

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
