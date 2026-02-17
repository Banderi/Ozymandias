tool
extends Label
class_name LabelEx

export var localized_key = ""
func _enter_tree():
	if !Engine.is_editor_hint():
		if localized_key != "":
			text = localized_key
func _process(delta):
	Assets.editor_debug_translate_labels(self)
