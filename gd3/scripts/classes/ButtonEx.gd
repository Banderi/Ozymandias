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

# styleboxtexture quickset helpers
export var button_texture_path : String = "Pharaoh_General/paneling" setget set_texture_button_path
export var button_texture_id : int = -1 setget set_texture_button_id
export var button_texture_disabled_opacity : float = 1.0 setget set_texture_button_disabled_opacity
func set_texture_button_path(asset_rel_path):
	button_texture_path = asset_rel_path
func set_texture_button_id(button_id):
	button_texture_id = button_id
	if button_texture_id == -1 || button_texture_path == "":
		return
	var path = str("res://assets/Pharaoh/", button_texture_path, "/")
	var def_texture = texture_stylebox("%s%05d.png" % [path, button_id])
	rect_size = def_texture.texture.get_size()
	rect_min_size = rect_size
	set("custom_styles/normal", def_texture)
	set("custom_styles/hover", texture_stylebox("%s%05d.png" % [path, button_id + 1]))
	set("custom_styles/pressed", texture_stylebox("%s%05d.png" % [path, button_id + 2]))
	var dis_texture = texture_stylebox("%s%05d.png" % [path, button_id + 3])
	dis_texture.modulate_color.a = button_texture_disabled_opacity
	set("custom_styles/disabled", dis_texture)
func texture_stylebox(path) -> StyleBoxTexture:
	var image = load(path)
	if image != null:
		var stylebox = StyleBoxTexture.new()
		stylebox.texture = image
		return stylebox
	return null
func set_texture_button_disabled_opacity(opacity):
	button_texture_disabled_opacity = opacity
	get("custom_styles/disabled").modulate_color.a = button_texture_disabled_opacity

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
