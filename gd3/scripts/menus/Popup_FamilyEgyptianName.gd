extends Control

func _on_BtnOk_pressed():
	if selected_item == null:
		Game.go_to_menu("NewFamily")
	else:
		Game.go_to_menu("NewFamily", TranslationServer.translate(selected_item.text))

func _gui_input(event):
	if Game.right_click_pressed(self, event):
		hide()

func unselect_all():
	for n in $Panel/FemaleNames/VBoxContainer.get_children():
		n.pressed = false
	for n in $Panel/MaleNames/VBoxContainer.get_children():
		n.pressed = false
	selected_item = null

func _on_popup_open(data):
	unselect_all()

var selected_item = null
func _on_any_pressed(node):
	unselect_all()
	selected_item = node

func _ready():
	for n in $Panel/FemaleNames/VBoxContainer.get_children():
		n.connect("pressed", self, "_on_any_pressed", [n])
	for n in $Panel/MaleNames/VBoxContainer.get_children():
		n.connect("pressed", self, "_on_any_pressed", [n])
