extends TextureRect

func _on_BtnCreateFamily_pressed():
	Game.go_to_menu("NewFamily", "")
func _on_BtnDeleteFamily_pressed():
	Game.popup_menu("DeleteFamily")
func _on_BtnProceed_pressed():
	Game.go_to_menu("GameSelection", selected_family_name)
func _on_BtnBack_pressed():
	Game.go_to_menu("Main")

var selected_family_name = null
func _on_BtnFamilyListing_pressed(family_name):
	$Panel/BtnProceed.disabled = false
	selected_family_name = family_name
#func unselect_all():
#	for n in $Panel/Panel/OzyScrollContainer/Control/VBoxContainer.get_children():
#		n.pressed = false
#	selected_family_name = null

onready var family_name_list_item_TSCN = load("res://scenes/UI/ListItems/ListingButton.tscn")
func _on_menu_open(data):
	if family_name_list_item_TSCN == null:
		yield(self, "ready")
	$Panel/BtnProceed.disabled = true
	Family.enumerate_families()
	
	var family_names_list = $Panel/Panel/OzyScrollContainer/Control/VBoxContainer 
	for n in family_names_list.get_children():
		n.queue_free()
	
	for family_name in Family.families_data:
		var node = family_name_list_item_TSCN.instance()
		node.text = family_name
		node.connect("pressed", self, "_on_BtnFamilyListing_pressed", [family_name])
		if node.text == data:
			node.pressed = true
			node.font_update()
			_on_BtnFamilyListing_pressed(data)
		family_names_list.add_child(node)

func _gui_input(event):
	if Game.right_click_pressed(self, event):
		_on_BtnBack_pressed()
