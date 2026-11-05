extends RichTextLabel
class_name RichTextLabelEx

enum ExpandDirections {
	None,
	Right,
	BottomRight,
	Bottom,
	BottomLeft,
	Left,
	TopLeft,
	Top,
	TopRight
}

export var AutoResize: bool = false
export(ExpandDirections) var ExpandDirection = ExpandDirections.BottomRight

var FONT = null
var STYLEBOX = null

func resize_around_text():
	
	var prev_pos = rect_position
	var prev_size = rect_size
	var prev_rightedge = prev_pos + prev_size
	
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

	# TODO
#	if ExpandDirection == 1:
#		rect_position.x = prev_rightedge.x - rect_size.x

func _ready():
	FONT = get("custom_fonts/normal_font")
	if FONT == null:
		FONT = get_theme_default_font()
	STYLEBOX = get_stylebox("normal")
	if AutoResize && STYLEBOX != null:
		resize_around_text()

# Called every frame. 'delta' is the elapsed time since the previous frame.
onready var prev_h = text.hash()
func _process(delta):
	if !is_visible_in_tree():
		return
	var h = text.hash()
	if h != prev_h:
		
		# stylebox
		if AutoResize && STYLEBOX != null:
			resize_around_text()
		
		prev_h = h
