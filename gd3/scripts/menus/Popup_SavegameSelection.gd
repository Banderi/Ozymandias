extends Control

func _on_BtnDelete_pressed():
	pass # Replace with function body.
func _on_BtnProceed_pressed():
	pass # Replace with function body.

var selected_save = null
func _on_BtnListing_pressed(save):
	$Panel/BtnProceed.disabled = false
	$Panel/BtnDelete.disabled = false
	selected_save = save
	$Panel/OzyLineEdit/LineEdit.text = save

onready var list_item_TSCN = load("res://scenes/UI/ListItems/ListingButton.tscn")
func _on_menu_open(data):
	if list_item_TSCN == null:
		yield(self, "ready")
	$Panel/BtnProceed.disabled = true
	$Panel/BtnDelete.disabled = true
#	Family.enumerate_families()

	selected_save = Family.get_most_recent_family_save()
	$Panel/OzyLineEdit/LineEdit.text = selected_save if selected_save != null else ""
	
	var list_node = $Panel/OzyScrollPanel/Crop/VBoxContainer
	for n in list_node.get_children():
		n.queue_free()
	
	for save in Family.get_family_saves():
		var save_without_extension = save.replace(".sav", "")
		var node = list_item_TSCN.instance()
		node.text = save_without_extension
		node.connect("pressed", self, "_on_BtnListing_pressed", [save_without_extension])
#		if node.text == data:
#			node.pressed = true
#			node.font_update()
#			_on_BtnListing_pressed(data)
		list_node.add_child(node)

func _gui_input(event):
	if Game.right_click_pressed(self, event):
		hide()

