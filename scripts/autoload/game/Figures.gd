extends Node

# TODO: get these from gameset
const MAX_FIGURES = 2000
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

onready var figure_sprite_TSCN = load("res://scenes/FigureSprite.tscn")
func spawn_sprites():
	var _t = Stopwatch.start()
	for i in figures.size():
		var figure = figures[i]
		if figure.in_use():
			create_sprite(i)
	Stopwatch.stop(self, _t, "Figures.spawn_sprites")
func create_sprite(i):
	var n = figure_sprite_TSCN.instance()
	n.set_figure(i)
	Map.TILEMAP_FLAT.add_child(n) # TODO....
#	Map.TILEMAP_ANIM.add_child(n)
	figures[i].FigureSprite = n

func enscribe_figures():
	Scribe.push_compressed(Figures.MAX_FIGURES * 388)
	var _t = Stopwatch.start()
	var _empty = 0
	for i in Figures.MAX_FIGURES:
		var _p = ScribeMono.GetPosition()
		assert(_p % 388 == 0)
		if !figures[i].Fill(): # 3~5 ms compared to 30~50 ms with ScribeMono
			_empty += 1
	
	print("figures: %d (%d empty)    ms taken: %d" % [
		MAX_FIGURES - _empty,
		_empty,
		Stopwatch.query(_t)
	])
	Scribe.pop_compressed()

func _enter_tree():
	var FIGURE_CS = load("res://scripts/mono/Figure.cs")
	for i in MAX_FIGURES: # prepare array of figure objects
		figures.push_back(FIGURE_CS.new(i))
func _ready():
	assert(figures.size() == MAX_FIGURES)
