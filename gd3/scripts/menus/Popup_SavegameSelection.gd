extends Control

const CHUNK_SIZE = 1024
func get_file_hash(path, type) -> String: #  SHA-256
	var ctx = HashingContext.new()
	var file = File.new()
	ctx.start(type)
	file.open(path, File.READ)
	while not file.eof_reached():
		ctx.update(file.get_buffer(CHUNK_SIZE))
	var res = ctx.finish()
	return res.hex_encode()
func get_hash(path) -> String:
	return get_file_hash(path, HashingContext.HASH_SHA256)
func passed(a, b):
	return "✓" if a == b else "X "

var saving_mode = false # false = loading, true = saving
func _on_BtnDelete_pressed():
	
	
	var d = null
	
	# OG COMPRESSED
	d = IO.open("G:/OG_COMPR", File.READ) as File
	var og_compr_s = d.get_32()
	var og_compr_raw = d.get_buffer(og_compr_s)
	d.close()
	var hash_og_compr = get_hash("G:/OG_COMPR")
	
	# OG UNCOMPRESSED
	d = IO.open("G:/OG_GRID", File.READ) as File
	var og_grid = d.get_buffer(Map.PH_MAP_SIZE * 4)
	d.close()
	var hash_og_grid = get_hash("G:/OG_GRID")
	
	
	# test: compression
	var rc = PKWareMono.Deflate(og_grid, 4096)
	d = IO.open("G:/test", File.WRITE) as File
	d.store_32(rc.size())
	d.store_buffer(rc)
	d.close()
	var hash_cs_compr = get_hash("G:/test")
#	var hash_cs_compr = "----------------------------------------------------------------"
#	rc = PKWare.compress(og_grid, 4096)
#	d = IO.open("G:/test", File.WRITE) as File
#	d.store_32(rc.size())
#	d.store_buffer(rc)
#	d.close()
#	var hash_gds_compr = get_hash("G:/OG_COMPR")
	var hash_gds_compr = "----------------------------------------------------------------"
	
	
	# test 2: decompression
	var dc = PKWareMono.Inflate(og_compr_raw, Map.PH_MAP_SIZE * 4)
	d = IO.open("G:/test3", File.WRITE) as File
	d.store_buffer(dc)
	d.close()
	var hash_cs_grid = get_hash("G:/test3")
	dc = PKWare.decompress(og_compr_raw, Map.PH_MAP_SIZE * 4) # around ~140 ms
	d = IO.open("G:/test4", File.WRITE) as File
	d.store_buffer(dc)
	d.close()
	var hash_gds_grid = get_hash("G:/test4")
	
	
	print("               COMPRESSED                                                           UNCOMPRESSED")
	print("ORIGINAL:      %s     %s" % [hash_og_compr, hash_og_grid])
#	print("------------------------------------------------------------------------------------------------------------------------------------------------------")
	print("Mono/C#:       %s %s  %s %s" % [hash_cs_compr, passed(hash_cs_compr, hash_og_compr), hash_cs_grid, passed(hash_cs_grid, hash_og_grid)])
	print("GDScript:      %s %s  %s %s" % [hash_gds_compr, passed(hash_gds_compr, hash_og_compr), hash_gds_grid, passed(hash_gds_grid, hash_og_grid)])
	
	
	
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

