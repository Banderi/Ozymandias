extends Node

onready var CS_ENUMS = load("res://scripts/mono/Enums.cs").new().GetEnums()

func enum_print_bbcode(enum_dict, value):
	var enum_name = enum_dict.get(value, null)
	if enum_name == null:
		return "[color=#dd0000]%d:??[/color]" % [value]
	else:
		return "%d:%s" % [value, enum_name]
