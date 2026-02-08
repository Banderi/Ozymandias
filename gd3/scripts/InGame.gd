extends Node2D

func camera_movements(event):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) && event is InputEventMouseMotion:
		pass

func _input(event):
	if Game.STATE == Game.States.Ingame:
		camera_movements(event)
