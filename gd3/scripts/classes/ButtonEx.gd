tool
extends Button
class_name ButtonEx

export var toggled_list_item : bool = false

# custom fonts by state
export var font_normal : BitmapFont = null
export var font_pressed : BitmapFont = null
export var font_hovered : BitmapFont = null
func set_font(font):
	if font != null:
		set("custom_fonts/font", font)
func font_update():
	if hovering || parent_hovering:
		if pressed:
			set_font(font_pressed)
		else:
			set_font(font_hovered)
	else:
		if pressed:
			set_font(font_pressed)
		else:
			set_font(font_normal)

# hovering update, container fallthrough, user events
var parent_hovering = false
var hovering = false
var asks_update = false
func _on_Button_mouse_entered(by_parent_fallthrough = false):
	if by_parent_fallthrough:
		parent_hovering = true
	else:
		hovering = true
	asks_update = true
func _on_Button_mouse_exited(by_parent_fallthrough = false):
	if by_parent_fallthrough:
		parent_hovering = false
	else:
		hovering = false
	asks_update = true
func _on_Button_toggled(_button_pressed):
	asks_update = true
func _on_Button_pressed():
	if toggled_list_item:
		for n in get_parent().get_children():
			n.pressed = false
		pressed = true

func hover_stylebox_update(): # TODO
	if hovering || parent_hovering:
		pass
	else:
		pass

func _input(event):
	if asks_update:
		font_update()
		hover_stylebox_update() # TODO
		asks_update = false

export var localized_key = ""
func _enter_tree():
	if localized_key != "":
		text = localized_key
func _process(delta):
	Assets.editor_debug_translate_labels(self)

func _ready():
	connect("pressed", self, "_on_Button_pressed")
	connect("toggled", self, "_on_Button_toggled")
	connect("mouse_entered", self, "_on_Button_mouse_entered")
	connect("mouse_exited", self, "_on_Button_mouse_exited")
