tool
extends Control

export var value = 0 setget update_scrollbar_from_value_PRE_TREE
export var min_value = 0
export var max_value = 100
export var step_size = 1

signal scrolled(value)

# this is a HORRIFIC hack needed because Godot will fire the setget BEFORE entering tree AND BEFORE setting the other exports from the editor.
func update_scrollbar_from_value_PRE_TREE(v):
	call_deferred("update_scrollbar_from_value", v)
func _ready():
	update_scrollbar_from_value_PRE_TREE(value) # sigh...

func update_scrollbar_from_value(v : int):
	value = clamp(v, min_value, max_value)
	update_and_emit()
func update_scrollbar_from_grabber():
	value = int((grabber.rect_position.y - 26) / float(rect_size.y - 78) * (max_value - min_value)) + min_value
	update_and_emit()
func update_and_emit():
	if grabber == null:
		grabber = $BtnGrabber
		
	if max_value == min_value: # can not scroll -- 
		grabber.hide()
		btn_up.disabled = true
		btn_down.disabled = true
		return false
	else:
		grabber.show()
		btn_up.disabled = false
		btn_down.disabled = false
		grabber.rect_position.y = 26 + (rect_size.y - 78) / float(max_value - min_value) * (value - min_value)
		grabber.rect_position.x = 5.5
		emit_signal("scrolled", value)

onready var grabber = $BtnGrabber
var grabber_mouse_click_delta = 0
func _on_BtnGrabber_gui_input(_event): # continuous grabber dragging event
	if grabber.pressed:
		grabber.rect_position.y = clamp(get_local_mouse_position().y + grabber_mouse_click_delta, 26, rect_size.y - 52)
		update_scrollbar_from_grabber()
func _on_BtnGrabber_pressed(): # on initial click/grab
	grabber_mouse_click_delta = grabber.rect_position.y - get_local_mouse_position().y
	return _on_BtnGrabber_gui_input(null)


var btn_timer = 0
onready var btn_up = $BtnUp
onready var btn_down = $BtnDown
func scroll_delta(delta):
	update_scrollbar_from_value(value + delta * step_size)

func _process(delta):
	if (Engine.editor_hint):
		return
	
	if btn_timer == 0.0 || btn_timer >= 0.25:
		if btn_up.pressed:
			scroll_delta(-delta * 60.0)
		elif btn_down.pressed:
			scroll_delta(delta * 60.0)
	
	# update button timer
	if btn_up.pressed || btn_down.pressed:
		btn_timer += delta
	else:
		btn_timer = 0
func _input(event):
	if event is InputEventMouseButton && event.pressed && get_global_rect().has_point(get_global_mouse_position()):
		match event.button_index:
			BUTTON_WHEEL_UP:
				scroll_delta(-2)
			BUTTON_WHEEL_DOWN:
				scroll_delta(2)
