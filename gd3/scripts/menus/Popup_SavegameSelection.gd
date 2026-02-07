extends Control

var saving_mode = false # false = loading, true = saving
func _on_BtnDelete_pressed():
	
	
	# testing
	var d = IO.open("G:/test2")
	var fs = d.get_32()
	var buf = d.get_buffer(fs)
	
	var t = Stopwatch.start()
#	var dc = PKWare.decompress(buf, Map.PH_MAP_SIZE * 4) # around ~140 ms
	var dc = PKWareMono.decompress(buf, Map.PH_MAP_SIZE * 4) # around ~140 ms
	Stopwatch.stop(null, t, "decomp test", Stopwatch.Milliseconds)
	
	
	d.close()
	
	
	
	
	
	pass # Replace with function body.
func _on_BtnProceed_pressed():
	if selected_save == null:
		return
	if saving_mode:
		Game.save_game(Family.get_current_save_path() + "/" + selected_save + ".sav")
	else:
		Game.load_game(Family.get_current_save_path() + "/" + selected_save + ".sav")

var selected_save = null
func _on_BtnListing_pressed(save):
	$Panel/BtnProceed.disabled = false
	$Panel/BtnDelete.disabled = false
	selected_save = save
	$Panel/OzyLineEdit/LineEdit.text = save


onready var list_item_TSCN = load("res://scenes/UI/ListItems/ListingButton.tscn")
func _on_menu_open(mode):
	if list_item_TSCN == null:
		yield(self, "ready")
	
	# saving / loading mode
	saving_mode = mode
	if saving_mode:
		$Panel/LabelEx.text = "TEXT_43_0"
	else:
		$Panel/LabelEx.text = "TEXT_43_1"
	
	
	# current selected save (LineEditEx)
	$Panel/BtnProceed.disabled = true
	$Panel/BtnDelete.disabled = true
	selected_save = Family.get_most_recent_family_save().replace(".sav", "")
	$Panel/OzyLineEdit/LineEdit.text = selected_save if selected_save != null else ""
	
	# listed saves
	var list_node = $Panel/OzyScrollPanel/Crop/VBoxContainer
	for n in list_node.get_children():
		n.queue_free()
	for save in Family.get_family_saves():
		var save_without_extension = save.replace(".sav", "")
		var node = list_item_TSCN.instance()
		node.text = save_without_extension
		node.connect("pressed", self, "_on_BtnListing_pressed", [save_without_extension])
		if node.text == selected_save:
			node.pressed = true
			node.font_update()
			_on_BtnListing_pressed(selected_save)
		list_node.add_child(node)

func _gui_input(event):
	if Game.right_click_pressed(self, event):
		hide()

