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
func spawn_sprites(): # TODO
	var _t = Stopwatch.start()
	
	for i in figures.size():
		var figure = figures[i]
		if figure.getData("type") != 0:
			var n = figure_sprite_TSCN.instance()
			n.set_figure(i)
			
			Map.TILEMAP_FLAT.add_child(n)
#			Map.TILEMAP_ANIM.add_child(n)
	
	Stopwatch.stop(self, _t, "Figures.spawn_sprites")

#var FIGURE_CS = load("res://scripts/mono/Figure.cs")
func enscribe_figures():
	Scribe.push_compressed(Figures.MAX_FIGURES * 388)
	var _t = Stopwatch.start()
	var _skipped = 0
	for i in Figures.MAX_FIGURES:
		var _p = ScribeMono.GetPosition()
		assert(_p % 388 == 0)
		
#		if i == 1:
#		var ftest = FIGURE_CS.new()
		var ftest = figures[i]
		ftest.Fill()
#		var a = ftest.getData("anim_frame")
#		var b = ftest.getData("sprite_image_id")
#		var c = ftest.getData("type")
#		ftest.setData("type", 99)
#		c = ftest.getData("type")
#		var _p2 = ScribeMono.GetPosition()
		
#		Figures.figures.push_back(ftest)
		continue
		
		##################
		
		Scribe.sync_record([Figures.figures, i], TYPE_DICTIONARY)
	
		Scribe.put(ScribeFormat.u8, "alternative_location_index")
		Scribe.put(ScribeFormat.u8, "anim_frame")
		Scribe.put(ScribeFormat.u8, "is_enemy_image")
		Scribe.put(ScribeFormat.u8, "flotsam_visible")
		Scribe.put(ScribeFormat.i16, "sprite_image_id") # this is off by 18 with respect to the normal SG global ids!
		if Assets.GAME_SET == "C3":
			Scribe.put(ScribeFormat.i16, "cart_image_id")
		elif Assets.GAME_SET == "Pharaoh":
			Scribe.skip(2)
		Scribe.put(ScribeFormat.i16, "next_figure")
		Scribe.put(ScribeFormat.u8, "type")
		
#		var a = figures[i]
		
		if figures[i].type == 0:
			_skipped += 1
			Scribe.skip(388 - 11)
			continue
		
		Scribe.put(ScribeFormat.u8, "resource_id")
		Scribe.put(ScribeFormat.u8, "use_cross_country")
		Scribe.put(ScribeFormat.u8, "is_friendly")
		Scribe.put(ScribeFormat.u8, "state")
		Scribe.put(ScribeFormat.u8, "faction_id")
		Scribe.put(ScribeFormat.u8, "action_state_before_attack")
		Scribe.put(ScribeFormat.i8, "direction")
		Scribe.put(ScribeFormat.i8, "previous_tile_direction")
		Scribe.put(ScribeFormat.i8, "attack_direction")
		Scribe.put(ScribeFormat.u16, "tile_x")
		Scribe.put(ScribeFormat.u16, "tile_y")
		Scribe.put(ScribeFormat.u16, "previous_tile_x")
		Scribe.put(ScribeFormat.u16, "previous_tile_y")
		Scribe.put(ScribeFormat.u16, "missile_damage")
		Scribe.put(ScribeFormat.u16, "damage")
		Scribe.put(ScribeFormat.i32, "tile_grid")
		Scribe.put(ScribeFormat.u16, "destination_tile_x")
		Scribe.put(ScribeFormat.u16, "destination_tile_y")
		Scribe.put(ScribeFormat.i32, "destination_tile_grid")
		Scribe.put(ScribeFormat.u16, "source_tile_x")
		Scribe.put(ScribeFormat.u16, "source_tile_y")
		Scribe.put(ScribeFormat.u16, "formation_position_x.soldier")
		Scribe.put(ScribeFormat.u16, "formation_position_y.soldier")
		Scribe.put(ScribeFormat.i16, "__unused_24") # 0
		Scribe.put(ScribeFormat.i16, "wait_ticks") # 0
		Scribe.put(ScribeFormat.u8, "action_state") # 9
		Scribe.put(ScribeFormat.u8, "progress_on_tile") # 11
		Scribe.put(ScribeFormat.i16, "routing_path_id") # 12
		Scribe.put(ScribeFormat.i16, "routing_path_current_tile") # 4
		Scribe.put(ScribeFormat.i16, "routing_path_length") # 28
		Scribe.put(ScribeFormat.u8, "in_building_wait_ticks") # 0
		Scribe.put(ScribeFormat.u8, "outside_road_ticks") # 1
		Scribe.put(ScribeFormat.i16, "max_roam_length")
		Scribe.put(ScribeFormat.i16, "roam_length")
		Scribe.put(ScribeFormat.u8, "roam_wander_freely")
		Scribe.put(ScribeFormat.u8, "roam_random_counter")
		Scribe.put(ScribeFormat.i8, "roam_turn_direction")
		Scribe.put(ScribeFormat.i8, "roam_ticks_until_next_turn") # 0 ^^^^
		Scribe.put(ScribeFormat.i16, "cc_coords.x")
		Scribe.put(ScribeFormat.i16, "cc_coords.y")
		Scribe.put(ScribeFormat.i16, "cc_destination.x")
		Scribe.put(ScribeFormat.i16, "cc_destination.y")
		Scribe.put(ScribeFormat.i16, "cc_delta.x")
		Scribe.put(ScribeFormat.i16, "cc_delta.y")
		Scribe.put(ScribeFormat.i16, "cc_delta_xy")
		Scribe.put(ScribeFormat.u8, "cc_direction")
		Scribe.put(ScribeFormat.u8, "speed_multiplier")
		Scribe.put(ScribeFormat.i16, "home_building_id")
		Scribe.put(ScribeFormat.i16, "immigrant_home_building_id")
		Scribe.put(ScribeFormat.i16, "destination_building_id")
		Scribe.put(ScribeFormat.i16, "formation_id") # formation: 10
		Scribe.put(ScribeFormat.u8, "index_in_formation") # 3
		Scribe.put(ScribeFormat.u8, "formation_at_rest")
		Scribe.put(ScribeFormat.u8, "migrant_num_people")
		Scribe.put(ScribeFormat.u8, "is_ghost")
		Scribe.put(ScribeFormat.u8, "min_max_seen")
		Scribe.put(ScribeFormat.u8, "__unused_57")
		Scribe.put(ScribeFormat.i16, "leading_figure_id")
		Scribe.put(ScribeFormat.u8, "attack_image_offset")
		Scribe.put(ScribeFormat.u8, "wait_ticks_missile")
		Scribe.put(ScribeFormat.i8, "cart_offset.x")
		Scribe.put(ScribeFormat.i8, "cart_offset.y")
		Scribe.put(ScribeFormat.u8, "empire_city_id")
		Scribe.put(ScribeFormat.u8, "trader_amount_bought")
		Scribe.put(ScribeFormat.i16, "name") # 6
		Scribe.put(ScribeFormat.u8, "terrain_usage")
		Scribe.put(ScribeFormat.u8, "is_boat")
		Scribe.put(ScribeFormat.u16, "resource_amount_full") # 4772 >>>> 112 (resource amount! 2-bytes)
		Scribe.put(ScribeFormat.u8, "height_adjusted_ticks")
		Scribe.put(ScribeFormat.u8, "current_height")
		Scribe.put(ScribeFormat.u8, "target_height")
		Scribe.put(ScribeFormat.u8, "collecting_item_id")
		Scribe.put(ScribeFormat.u8, "trade_ship_failed_dock_attempts")
		Scribe.put(ScribeFormat.u8, "phrase_sequence_exact")
		Scribe.put(ScribeFormat.i8, "phrase_id")
		Scribe.put(ScribeFormat.u8, "phrase_sequence_city")
		Scribe.put(ScribeFormat.u8, "__unused_6f")
		Scribe.put(ScribeFormat.u8, "trader_id")
		Scribe.put(ScribeFormat.u8, "wait_ticks_next_target")
		Scribe.put(ScribeFormat.i16, "target_figure_id")
		Scribe.put(ScribeFormat.i16, "targeted_by_figure_id")
		Scribe.put(ScribeFormat.u16, "created_sequence")
		Scribe.put(ScribeFormat.u16, "target_figure_created_sequence")
	#    Scribe.put(ScribeFormat.u8, "figures_sametile_num")
		Scribe.skip(1)
		Scribe.put(ScribeFormat.u8, "num_attackers")
		Scribe.put(ScribeFormat.i16, "attacker_id1")
		Scribe.put(ScribeFormat.i16, "attacker_id2")
		Scribe.put(ScribeFormat.i16, "opponent_id")
		if Assets.GAME_SET == "Pharaoh":
	#        Scribe.skip(239")
			Scribe.skip(7)
			Scribe.put(ScribeFormat.i16, "unk_ph1_269") # 269
			Scribe.put(ScribeFormat.i16, "unk_ph2_00") # 0
			Scribe.put(ScribeFormat.i32, "market_lady_resource_image_offset") # 03 00 00 00
			Scribe.skip(12) # FF FF FF FF FF ...
			Scribe.put(ScribeFormat.i16, "market_lady_returning_home_id") # 26
			Scribe.skip(14) # 00 00 00 00 00 00 00 ...
			Scribe.put(ScribeFormat.i16, "market_lady_bought_amount") # 200
			Scribe.skip(115)
			Scribe.put(ScribeFormat.i8, "unk_ph3_6") # 6
			Scribe.put(ScribeFormat.i16, "unk_ph4_ffff") # -1
			Scribe.skip(48)
			Scribe.put(ScribeFormat.i8, "festival_remaining_dances")
			Scribe.skip(27)
			Scribe.put(ScribeFormat.i16, "cart_image_id") # this is off by 18 with respect to the normal SG global ids!
			Scribe.skip(2)
	
	print("figures: %d (%d skipped)    ms taken: %d" % [
		MAX_FIGURES - _skipped,
		_skipped,
		Stopwatch.query(_t)
	])
	Scribe.pop_compressed()
	

func _enter_tree():
	var FIGURE_CS = load("res://scripts/mono/Figure.cs")
	for i in MAX_FIGURES: # prepare empty array
#		figures.push_back({})
		figures.push_back(FIGURE_CS.new())
func _ready():
	assert(figures.size() == MAX_FIGURES)
