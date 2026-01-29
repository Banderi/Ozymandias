@tool
extends Panel

@export var snap : int = 16
@export var exclusive_input : bool = false

func _on_TextureRect_resized():
	size.x = round(size.x / float(snap)) * snap
	size.y = round(size.y / float(snap)) * snap

signal clicked_outside(panel)
func _input(event):
	if exclusive_input && is_visible_in_tree() && !get_global_rect().has_point(get_global_mouse_position()):
		if event is InputEventMouseButton && event.pressed:
			emit_signal("clicked_outside", self)
		get_tree().set_input_as_handled()
