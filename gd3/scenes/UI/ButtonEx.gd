tool
extends Button
class_name ButtonEx

export var font_normal : BitmapFont = null
export var font_pressed : BitmapFont = null
export var font_hovered : BitmapFont = null

export var toggled_list_item : bool = false

func set_font(font):
	if font != null:
		set("custom_fonts/font", font)

func font_update():
	if hovering:
		if pressed:
			set_font(font_pressed)
		else:
			set_font(font_hovered)
	else:
		if pressed:
			set_font(font_pressed)
		else:
			set_font(font_normal)

var hovering = false
func _on_Button_mouse_entered():
	hovering = true
	font_update()
func _on_Button_mouse_exited():
	hovering = false
	font_update()
func _on_Button_toggled(_button_pressed):
	font_update()

func _on_Button_pressed():
	if toggled_list_item:
		for n in get_parent().get_children():
			n.pressed = false
		pressed = true

func _process(delta):
	Assets.editor_debug_translate_labels(self)
