extends RichTextLabel
class_name RichTextLabelEx

var FONT = null
var STYLEBOX = null

func _ready():
	FONT = get("custom_fonts/normal_font")
	if FONT == null:
		FONT = get_theme_default_font()
	STYLEBOX = get_stylebox("normal")

# Called every frame. 'delta' is the elapsed time since the previous frame.
onready var prev_h = text.hash()
func _process(delta):
#func _draw():
	var h = text.hash()
	if h != prev_h:
		
		# stylebox
		if STYLEBOX != null:
			var long = ""
			var lon = 0
			var lines = text.split("\n")
			for l in lines:
				if l.length() > lon:
					lon = l.length()
					long = l
			var line_sep = get("custom_constants/line_separation")
			rect_size.x = FONT.get_string_size(long).x + STYLEBOX.content_margin_left + STYLEBOX.content_margin_right
			rect_size.y = (lines.size() - 1) * (FONT.get_height() + line_sep) + STYLEBOX.content_margin_top + STYLEBOX.content_margin_bottom
		
		prev_h = h
