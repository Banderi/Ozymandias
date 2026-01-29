#tool
extends Node

var display_mode = 1

var canvas = null
var debug_text = null
var fps_label = null

func init_nodes(node, skip_extra_nodes = false):
	canvas = node
	debug_text = null
	fps_label = null
	if !skip_extra_nodes:
		debug_text = canvas.get_node("debug_text")
#		fps_label = canvas.get_node("FPS")

func padvalues(paired, paddings, values):
	var txt = ""
	for i in values.size():
		var s = str(values[i])
		var p = 0 # default: 0

		var pad_i = i # default
		if paired:
			pad_i = (i - 1) / 2

		if paddings.size() > pad_i && (!paired || i % 2 != 0): # to make sure the first array is long enough
			p = paddings[pad_i]
		var string_length = s.length()

		# add text to buffer!
		txt += s
		for _w in range(0, p - string_length):
			txt += " "
		txt += " " # add a trailing space as default
	return txt
func prntpadded(txt, paired, paddings, values, color="yellow"):
	debug_text.append_bbcode(str("[color=", color, "]", txt, "[/color]", padvalues(paired, paddings, values), "\n"))
func prnt(txt, txt2 = "", color="yellow"):
	if str(txt2) != "":
		debug_text.append_bbcode(str("[color=", color, "]", txt, "[/color]", txt2, "\n"))
	else:
		debug_text.append_bbcode(str(txt, "\n"))
func prnt_newl():
	debug_text.append_bbcode("\n")

var floating_labels = []
func floating(txt, pos):
	floating_labels.append([txt, pos])

###

var debug_frame = 0
var todraw_empty = {
	"points": [],
	"lines": [],
}
func empty_geometry_render_queue():
	todraw = todraw_empty.duplicate(true) # TODO: change this garbage
var todraw = {
	"points": [],
	"lines": [],
}

# these ENSURE that clear() is called BEFORE rendering anything -- i.e. only clears the PREVIOUS frame!
var geometry_queued = false
var geometry_rendered = false

func canvas_is_ready():
	if Game.is_valid_objref(canvas) && canvas.is_visible_in_tree():
		return true
	return false

#var has_rendered = false
func Point(point, color):
	if !canvas_is_ready():
		return
	if canvas != null:
		todraw.points.push_back([point, color])
	geometry_queued = true
func Line(point_1, point_2, color_1, _color_2 = null, _standalone = true):
	if !canvas_is_ready():
		return
	if canvas != null:
		todraw.lines.push_back([point_1, point_2, color_1, 1])
	geometry_queued = true
func Vector(origin, vector, color, dot_1 = false, dot_2 = false):
	if !canvas_is_ready():
		return
	Line(origin, origin + vector, color)
	if dot_1:
		Point(origin, color)
	if dot_2:
		Point(origin + vector, color)
func BoxLines(p, x, y, z, c, centered = true, e = -1, points = false):
	if !canvas_is_ready():
		return
	if centered:
		p -= Vector3(x, y, z) * 0.5
	var vrt = [
		p,
		p + Vector3(x, 0, 0),
		p + Vector3(x, 0, z),
		p + Vector3(0, 0, z),

		p + Vector3(0, y, 0),
		p + Vector3(x, y, 0),
		p + Vector3(x, y, z),
		p + Vector3(0, y, z),
	]

	if e == -1:
		# bottom
		Line(vrt[0], vrt[1], c)
		Line(vrt[1], vrt[2], c)
		Line(vrt[2], vrt[3], c)
		Line(vrt[3], vrt[0], c)

		# top
		Line(vrt[4], vrt[5], c)
		Line(vrt[5], vrt[6], c)
		Line(vrt[6], vrt[7], c)
		Line(vrt[7], vrt[4], c)

		# walls
		Line(vrt[0], vrt[4], c)
		Line(vrt[1], vrt[5], c)
		Line(vrt[2], vrt[6], c)
		Line(vrt[3], vrt[7], c)
	else:
		for v in vrt.size():
			var vert = vrt[v]
			var edge = Vector3(e, e, e)
			if v >= 4:
				edge.y = -e
			if v % 4 in [1, 2]:
				edge.x = -e
			if v % 4 >= 2:
				edge.z = -e
			Line(vert, vert + edge * Vector3(1, 0, 0), c)
			Line(vert, vert + edge * Vector3(0, 1, 0), c)
			Line(vert, vert + edge * Vector3(0, 0, 1), c)
	if points:
		for v in vrt:
			Point(v, c)
func Box(p, s, c, centered = true, e = -1, points = false):
	if !canvas_is_ready():
		return
	return BoxLines(p, s.x, s.y, s.z, c, centered, e, points)

func update_display_mode():
	# cycle display mode
	if display_mode > 2:
		display_mode = 0

	match display_mode:
		0:
			pass
		1:
			pass
func _process(_delta):
	if !Engine.editor_hint:
		update_display_mode()

	# clear text log
	if Game.is_valid_objref(debug_text):
		debug_text.text = ""

	if !Game.is_valid_objref(canvas):
		return

	if !display_mode:
		canvas.visible = false
		for picker in Game.PICKER_AREA:
			picker.hide()
	else:
		canvas.visible = true
		for picker in Game.PICKER_AREA:
			picker.show()

	if canvas.visible:

		# refresh and prepare for next draw
		if geometry_rendered:
			geometry_rendered = false

	# fps label
	if Game.is_valid_objref(fps_label):
		fps_label.text = str(Engine.get_frames_per_second(), " FPS")
	debug_frame += 1
func _input(_event):
	if !Engine.editor_hint:
		if Game.debug_tools_enabled() && Input.is_action_just_pressed("debug_key"):
			display_mode += 1

func _ready():
	self.set_pause_mode(2) # Set pause mode to Process
	set_process(true)
