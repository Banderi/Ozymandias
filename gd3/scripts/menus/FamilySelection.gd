extends TextureRect

func _on_BtnCreateFamily_pressed():
	pass # Replace with function body.
func _on_BtnDeleteFamily_pressed():
	pass # Replace with function body.
func _on_BtnProceed_pressed():
	Game.open_menu("GameSelection")
func _on_BtnBack_pressed():
	hide()

func _on_BtnFamilyListing_pressed(family_name):
	$Panel/BtnProceed.disabled = false
	Family.current_family = family_name

onready var family_name_list_item_TSCN = load("res://scenes/UI/ListItems/ListingButton.tscn")
func _on_FamilySelection_visibility_changed():
	if visible:
		
		Family.enumerate_families()
		
		var family_names_list = $Panel/Panel/OzyScrollContainer/Control/VBoxContainer 
		for n in family_names_list.get_children():
			n.queue_free()
		
		for family_name in Family.families_data:
			var node = family_name_list_item_TSCN.instance()
			node.text = family_name
			node.connect("pressed", self, "_on_BtnFamilyListing_pressed", [family_name])
			family_names_list.add_child(node)

func _gui_input(event):
	if Game.right_click_pressed(self, event):
		_on_BtnBack_pressed()
