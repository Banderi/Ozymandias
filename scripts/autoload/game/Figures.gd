extends Node

# TODO: get these from gameset
const MAX_FIGURES = 2000 # REMEMBER ---- the first id in the stack (0) is a NULL/DUMMY FIGURE OBJECT and can NOT BE USED.
const MAX_ROUTES = 1000
const MAX_FORMATIONS = 50
const MAX_TRADERS = 100
const MAX_FERRIES = 50
const MAX_FIGURES_PER_FERRY = 11
const MAX_FIGURES_WAITING_PER_FERRY = 56

var figures = []
var figure_names_1 = []
var figure_names_2 = []
var figure_names_3 = []
var figure_sequence = 0
var figure_traders = []
var next_free_trader_index = 0

# formations
var formations = []
var last_used_formation
var last_formation_id
var total_formations

# ferries
var ferry_queues = []
var ferry_transiting = []

# figure sprites
func spawn_sprites():
	var _t = Stopwatch.start()
	for i in figures.size():
		var figure = figures[i]
		if figure.in_use():
			create_sprite(i)
	Stopwatch.stop(self, _t, "Figures.spawn_sprites")
func create_sprite(i):
	Map.TILEMAP_FLAT.add_child(FigureSprite.new(i, figures[i]))
#	var sprite = FigureSprite.new(i, figures[i])
#	Map.TILEMAP_FLAT.add_child(sprite) # TODO....
#	sprite.on_tick()
	
#	var n = figure_sprite_TSCN.instance()
#	n.set_figure(i)
#	Map.TILEMAP_FLAT.add_child(n) # TODO....
##	Map.TILEMAP_ANIM.add_child(n)
#	figures[i].FigureSprite = n
	pass

# figure C# objects
var FIGURE_CS = null
func init_figure_stack(): # prepare array of figure objects
	if figures != []:
		Log.warning(self, "Attempting to re-init non-empty Figures stack. Clearing...")
		figures = []
	if FIGURE_CS == null:
		FIGURE_CS = load("res://scripts/mono/" + Assets.GAME_SET + "/Figure.cs")
	for i in MAX_FIGURES:
		figures.push_back(FIGURE_CS.new(i))
	assert(figures.size() == MAX_FIGURES)
func spawn(): # TODO
	pass

# scribe
var _in_use = 0
func enscribe_figures():
	Scribe.push_compressed(MAX_FIGURES * 388)
	var _t = Stopwatch.start()
	_in_use = 0
	for i in MAX_FIGURES:
		var _p = ScribeMono.GetPosition()
		assert(_p % 388 == 0)
		var figure = figures[i]
		figure.Fill() # 3~5 ms compared to 30~50 ms with ScribeMono
		if figure.in_use():
			_in_use += 1
	
	print("figures:   %4d / %d    ms taken: %3d" % [
		_in_use,
		MAX_FIGURES,
		Stopwatch.query(_t)
	])
	Scribe.pop_compressed()

func tick():
	for f in figures:
		f.tick()
		continue
#		if f.IN_USE:
		if f.in_use(): # call or direct var is pretty much the same speed
#		if f.get("state") != 0: # wayyy too slow
			f.tick()
			pass
func repaint_sprites(force_repaint: bool = false):
	var _t = Stopwatch.start()
	for sprite in get_tree().get_nodes_in_group("sprites"):
		sprite.repaint(force_repaint)
	if force_repaint:
		Stopwatch.stop(self, _t, "repaint_sprites", Stopwatch.Milliseconds)
