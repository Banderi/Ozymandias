extends ColorRect

func _input(event):
	if !visible:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		Overseers.close()
	if Game.right_click_pressed(self, event):
		Overseers.close()

onready var BUTTONS_ROOT = get_node("Panel/Footer")
onready var TABS_ROOT = get_node("Panel/Tabs")
var current_tab = null
func select_tab(tab):
	if tab == current_tab:
		return
	
	# hide / release previous
	if current_tab != null:
		TABS_ROOT.get_node(current_tab).hide()
		BUTTONS_ROOT.get_node("Btn" + current_tab).pressed = false
	
	# open new tab
	TABS_ROOT.get_node(tab).show()
	current_tab = tab

func _on_BtnLabor_pressed():
	select_tab("Labor")
func _on_BtnMilitary_pressed():
	select_tab("Military")
func _on_BtnPolitical_pressed():
	select_tab("Political")
func _on_BtnRatings_pressed():
	select_tab("Ratings")
func _on_BtnCommerce_pressed():
	select_tab("Commerce")
func _on_BtnGranaries_pressed():
	select_tab("Granaries")
func _on_BtnHealth_pressed():
	select_tab("Health")
func _on_BtnCulture_pressed():
	select_tab("Culture")
func _on_BtnEntertainment_pressed():
	select_tab("Entertainment")
func _on_BtnReligion_pressed():
	select_tab("Religion")
func _on_BtnTreasury_pressed():
	select_tab("Treasury")
func _on_BtnChief_pressed():
	select_tab("Chief")
func _on_BtnMonuments_pressed():
	select_tab("Monuments")

func _on_BtnBack_pressed():
	Overseers.close()

func _ready():
	select_tab("Granaries")
