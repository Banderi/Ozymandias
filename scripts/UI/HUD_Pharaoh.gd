#tool
extends Control

export var open: bool = true setget set_open

onready var TWEEN = $Tween
onready var MENU_BAR_TILING = $MenuBar
onready var MENU_EXPANDED = $MenuExpanded
onready var MENU_MINIMIZED = $MenuMinimized
onready var SHIELD_EXPANDED = $MenuExpanded/Base/SHIELD
onready var SHIELD_MINIMIZED = $MenuMinimized/Base/SHIELD

func set_open(o):
	open = o
	var target_size = (rect_size + Vector2(120, 0)) if !open else rect_size
	var target_size2 = (rect_size + Vector2(140, 0)) if !open else rect_size
	
	SHIELD_EXPANDED.show()
	SHIELD_MINIMIZED.show()
	MENU_EXPANDED.show()
	
	if open:
		TWEEN.interpolate_property(MENU_EXPANDED, "modulate",
				Color(1,1,1,0), Color(1,1,1,1), 0.1,
				Tween.TRANS_SINE, Tween.EASE_IN)
	TWEEN.interpolate_property(MENU_BAR_TILING, "rect_size",
			MENU_BAR_TILING.rect_size, target_size, 0.25,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	TWEEN.interpolate_property(MENU_EXPANDED, "rect_size",
			MENU_EXPANDED.rect_size, target_size, 0.25,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	TWEEN.start()
	if !open:
		TWEEN.interpolate_property(MENU_EXPANDED, "modulate",
				Color(1,1,1,1), Color(1,1,1,0), 0.5,
				Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	yield(TWEEN, "tween_completed")
	
	if open:
		MENU_EXPANDED.show()
#		MENU_MINIMIZED.hide()
	else:
		MENU_EXPANDED.hide()
#		MENU_MINIMIZED.show()
	
	SHIELD_EXPANDED.hide()
	SHIELD_MINIMIZED.hide()
	
#	if open:
#		get_node("MenuBar").rect_size = size
#		get_node("MenuFull").rect_size = size
#		get_node("MenuFull").show()
#		get_node("MenuMinimized").hide()
#	else:
#		get_node("MenuBar").rect_size = size
#		get_node("MenuFull").rect_size = size
#		get_node("MenuFull").hide()
#		get_node("MenuMinimized").show()

func _process(delta):
	visible = Game.STATE != Game.States.NoGameLoaded # TODO: signals?
func _ready():
	MENU_EXPANDED.show()
#	MENU_MINIMIZED.hide()
	MENU_MINIMIZED.show()


func _on_BtnOpenClose_pressed():
	set_open(!open)

func _on_BtnHousing_pressed():
	pass # Replace with function body.
func _on_BtnRoad_pressed():
	pass # Replace with function body.
func _on_BtnFood_pressed():
	pass # Replace with function body.
func _on_BtnIndustry_pressed():
	pass # Replace with function body.
func _on_BtnClearLand_pressed():
	pass # Replace with function body.
func _on_BtnDistribution_pressed():
	pass # Replace with function body.
func _on_BtnEntertainment_pressed():
	pass # Replace with function body.
func _on_BtnReligion_pressed():
	pass # Replace with function body.
func _on_BtnCulture_pressed():
	pass # Replace with function body.
func _on_BtnSanitation_pressed():
	pass # Replace with function body.
func _on_BtnGovernment_pressed():
	pass # Replace with function body.
func _on_BtnMilitary_pressed():
	pass # Replace with function body.

func _on_BtnOverseers_pressed():
	Game.popup_menu("Overseers")
func _on_BtnMap_pressed():
	pass # Replace with function body.

func _on_BtnUndo_pressed():
	pass # Replace with function body.
func _on_BtnMessages_pressed():
	pass # Replace with function body.
func _on_BtnTrouble_pressed():
	pass # Replace with function body.
func _on_BtnBriefing_pressed():
	pass # Replace with function body.

func _on_BtnLocustUnused_pressed():
	pass # Replace with function body.
