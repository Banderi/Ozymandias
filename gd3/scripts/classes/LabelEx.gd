tool
extends Label
class_name LabelEx

func _process(delta):
	Assets.editor_debug_translate_labels(self)
