tool
extends Panel

export var snap: int = 16

func _on_TextureRect_resized():
	rect_size.x = round(rect_size.x / float(snap)) * snap
	rect_size.y = round(rect_size.y / float(snap)) * snap

signal clicked_outside(panel)
func _input(event):
	if is_visible_in_tree() && !get_global_rect().has_point(get_global_mouse_position()):
		if event is InputEventMouseButton && event.pressed:
			emit_signal("clicked_outside", self)

func _on_OzyLineEdit_clicked_outside(panel):
	release_focus()
