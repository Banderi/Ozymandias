extends Node2D

# cursor
enum CursorShapes { # TODO
}
enum CursorStates {
	Nothing
}
var cursor_state = CursorStates.Nothing

# camera
onready var CAMERA = $Camera2D
onready var camera_position_target = CAMERA.position
onready var camera_zoom_target = 1.0
onready var camera_previous_game_coords = null
func camera_movements(event):
#	match cursor_state:
#		CursorStates.Nothing:
#			if Input.is_mouse_button_pressed(BUTTON_MIDDLE) && event is InputEventMouseMotion:
#				pass
	if event is InputEventMouseButton:
		if event.pressed:
			var zstep_coeff = 1.5
			if event.button_index == BUTTON_WHEEL_DOWN:
				camera_zoom_target *= zstep_coeff
			if event.button_index == BUTTON_WHEEL_UP:
				camera_zoom_target /= zstep_coeff
			camera_zoom_target = clamp(camera_zoom_target, pow(1/zstep_coeff, 4), pow(zstep_coeff, 4))
	
		if event.button_index == BUTTON_MIDDLE || event.button_index == BUTTON_RIGHT: # TODO: use key settings
			if camera_previous_game_coords == null && event.pressed:
				camera_previous_game_coords = CAMERA.position
			elif camera_previous_game_coords != null && !event.pressed:
				camera_previous_game_coords = null

var last_click_game_coords = [null, null, null]
var last_click_mousepos = [null, null, null]
var current_click_game_coords = [null, null, null]
var current_click_mousepos = [null, null, null]
func update_mouse_press_coords(button_id):
	var i = button_id - 1
	var coords = null
	var mousepos = null
	if Input.is_mouse_button_pressed(button_id):
		coords = get_local_mouse_position()
		mousepos = get_viewport().get_mouse_position()
		if last_click_game_coords[i] == null:
			last_click_game_coords[i] = coords
		if last_click_mousepos[i] == null:
			last_click_mousepos[i] = mousepos
	else:
		last_click_game_coords[i] = null
		last_click_mousepos[i] = null
	current_click_game_coords[i] = coords
	current_click_mousepos[i] = mousepos

func _input(event):
	if Game.STATE == Game.States.Ingame:
		
		update_mouse_press_coords(BUTTON_LEFT)
		update_mouse_press_coords(BUTTON_RIGHT)
		update_mouse_press_coords(BUTTON_MIDDLE)
		
		camera_movements(event)

func _process(delta):
	if Game.STATE == Game.States.Ingame:
		
		# camera zoom - TODO: setting for enabling smooth zoom
#		CAMERA.zoom = Viewports.clampdamp(CAMERA.zoom, Vector2.ONE * camera_zoom_target, 5.0, delta)
		CAMERA.zoom = Vector2.ONE * camera_zoom_target
		
		# camera panning
		if camera_previous_game_coords != null:
			# TODO: custom key & sensitivity settings
			var MOUSE_DRAG_CONT = BUTTON_RIGHT
			var MOUSE_DRAG_SIMPLE = BUTTON_MIDDLE
			
			if Input.is_mouse_button_pressed(MOUSE_DRAG_CONT):
				var delta_pos = current_click_mousepos[MOUSE_DRAG_CONT-1] - last_click_mousepos[MOUSE_DRAG_CONT-1]
				camera_position_target += delta_pos * camera_zoom_target* 0.25
			elif Input.is_mouse_button_pressed(MOUSE_DRAG_SIMPLE):
				var delta_pos = current_click_mousepos[MOUSE_DRAG_SIMPLE-1] - last_click_mousepos[MOUSE_DRAG_SIMPLE-1]
				camera_position_target = camera_previous_game_coords - delta_pos * camera_zoom_target
		var camera_pan_keyboard_delta = Vector2()
		if Input.is_key_pressed(KEY_UP):
			camera_pan_keyboard_delta.y -= 1
		if Input.is_key_pressed(KEY_DOWN):
			camera_pan_keyboard_delta.y += 1
		if Input.is_key_pressed(KEY_LEFT):
			camera_pan_keyboard_delta.x -= 1
		if Input.is_key_pressed(KEY_RIGHT):
			camera_pan_keyboard_delta.x += 1
		camera_position_target += camera_pan_keyboard_delta * camera_zoom_target * 10.0
		
		# TODO adaptive limits to playable scenario/map area
		camera_position_target.x = clamp(camera_position_target.x, -3000, 3000) # -6000, 6000
		camera_position_target.y = clamp(camera_position_target.y, 1250, 5750) # 0, 7000
		
		CAMERA.position = Vector2(stepify(camera_position_target.x, camera_zoom_target), stepify(camera_position_target.y, camera_zoom_target))
