extends Node

onready var CS_ENUMS = load("res://scripts/mono/Enums.cs").new().GetEnums()

func enum_print_bbcode(enum_dict, value):
	var enum_name = enum_dict.get(value, null)
	if enum_name == null:
		return "[color=#dd0000]%d:??[/color]" % [value]
	else:
		return "%d:%s" % [value, enum_name]

func load_testing_save():
#	yield(Game.load_game("res://tests/autosave.sav"), "completed")
#	yield(Game.load_game("res://tests/Alexandria.sav"), "completed")
#	yield(Game.load_game("res://tests/autosave_history.sav"), "completed")
	yield(Game.load_game("res://tests/SteamSaves/A-test1.sav"), "completed")
	pass
