extends Node

# this singleton contains the caches, consts and lookup tables related to SG paks and other gameset-dependent assets.
func _init_cache(cache: Dictionary, gameset: String):
	if !(gameset in cache):
		cache[gameset] = {}
func init_caches():
	_init_cache(SG_CACHE, Assets.GAME_SET)
	_init_cache(SPRITES_CACHE, Assets.GAME_SET)

func _get_table_element(cache: Dictionary, gameset: String, element = null):
	if !(gameset in cache):
		return Log.error("_get_cache_element", ERR_INVALID_PARAMETER, "game set '%s' is not implemented" % [gameset])
	var cc = cache[gameset]
	if element == null:
		return cc
	if (cc is Dictionary && !(element in cc)) || (cc is Array && element >= cc.size()):
#		return Log.error("_get_cache_element", ERR_DOES_NOT_EXIST, "element '%s' does not exist inside cache" % [element])
		return null
	return cc[element]
func _set_table_element(cache: Dictionary, gameset: String, element, value) -> bool:
	if !(gameset in cache):
		Log.error("_get_cache_element", ERR_INVALID_PARAMETER, "game set '%s' is not implemented" % [gameset])
		return false
	if element == null:
		cache[gameset] = value
		return true
	cache[gameset][element] = value
	return true

const SG_EXTENSION = {
	"Pharaoh": ".sg3" }
func get_SG_EXTENSION():
	return _get_table_element(SG_EXTENSION, Assets.GAME_SET)

const SG_PAKS = { # These are the ranges of game paks and how they're laid out in the global image lookup.
				  #                   start id        final id      start       end
	"Pharaoh": {  #                   (global)        (global)      (pak)      (pak)
		"Pharaoh_Unloaded": 	[		    1,            682,         1,       682],
		"SprMain": 				[		  683,          11007,         1,     10325],
		
		"Assyrian":				[		11008,          11906,         1,       899],
		"Enemy_1":				[		11008,          11736,         1,       729],
		"Canaanite":			[		11008,          11866,         1,       859],
		"Hittite":				[		11008,          11874,         1,       867],
		"Hyksos":				[		11008,          11906,         1,       899],
		"Kushite":				[		11008,          11866,         1,       859],
		"Libian":				[		11008,          11866,         1,       859],
		"Mitani":				[		11008,          11906,         1,       899],
		"Nubian":				[		11008,          11834,         1,       827],
		"Persian":				[		11008,          11874,         1,       867],
		"Phoenician":			[		11008,          11842,         1,       835],
		"Roman":				[		11008,          11882,         1,       875],
		"SeaPeople":			[		11008,          11841,         1,       834],
		
		"Pharaoh_General":		[		11907,          14452,       201,      2746],
		"Pharaoh_Terrain":		[		14453,          15767,       201,      1515],
		
		"sphinx1a":				[		15768,          15769,       201,       202],
		"sphinx1b":				[		15770,          15771,       201,       202],
		"sphinx1c":				[		15772,          15773,       201,       202],
		"sphinx1d":				[		15774,          15775,       201,       202],
		
		"obelisk5x5a":			[		15768,          15768,       201,       201],
		"obelisk3x3a":			[		15770,          15770,       201,       201],
		"obelisk_extra":		[		15776,          15791,       201,       216],
		
		"Temple_nile":			[		15792,          15829,       201,       238],
		"Temple_ra":			[		15792,          15829,       201,       238],
		"Temple_ptah":			[		15792,          15829,       201,       238],
		"Temple_seth":			[		15792,          15829,       201,       238],
		"Temple_bast":			[		15792,          15829,       201,       238],
		
		"Empire":				[		15830,          15830,       201,       201],
		
		"SprAmbient":			[		15831,          18764,         1,      2934],
		"Pharaoh_Fonts":		[		18765,          20104,       201,      1540],
		"Egyptian":				[		20105,          20883,         1,       779],
		"SprMain2":				[		20884,          23235,         1,      2352],
		"Expansion":			[		23236,          23935,       201,       900],
		
		"Pyramid":				[		23936,          24163,       201,       428],
		"Mastaba":				[		23936,          24935,       201,       900],
		"PyramidDummy":			[		23936,          24163,       201,       428],
		# ?? (dummy yellow squares until end)
		# canonical end = 25139
		
		# ---------------- non-canon order override!! ---------------- #
		
#		"Pyramid":				[		30000,          30227,       201,       428],

	} }
func get_SG_PAK(pak_name):
	return _get_table_element(SG_PAKS, Assets.GAME_SET, pak_name)

var SG_CACHE = {}
func get_SG_CACHE(pak_name: String):
	return _get_table_element(SG_CACHE, Assets.GAME_SET, pak_name)
func set_SG_CACHE(pak_name: String, data) -> bool:
	return _set_table_element(SG_CACHE, Assets.GAME_SET, pak_name, data)

const SG_ANIMS = { # this lists the sprite animation info for every official SG pak
	"Pharaoh": {
		"SprMain": [
			[32,	 1], # hunter arrow					 	  0
			[32,	 1], # hunter arrow shadow				  1
			[ 8,	12], # emigrant							  2
			[ 1,	 8],
			[ 8,	12], # engineer							  4
			[ 1,	 8],
			[ 8,	12], # fireman							  6
			[ 1,	 8],
			[ 8,	37],
			[ 8,	12], # delivery boy						  9
			[ 1,	 8],
			[ 5,	 1], # hunder_stick						 11
			[ 8,	12], # homeless							 12
			[ 1,	 8],
			[ 8,	12], # immigrant						 14
			[ 1,	 8],
			[ 8,	12], # market buyer						 16
			[ 1,	 8],
			[ 8,	12], # market seller					 18
			[ 1,	 8],
			[ 8,	12], # policeman						 20
			[ 1,	 8],
			[ 8,	 6],
			[ 8,	12], # crocodile						 23
			[ 1,	 8],
			[ 8,	 7],
			[ 8,	11],
			[ 8,	11],
			[ 8,	12], # pharaoh							 28
			[ 8,	12], # rioters							 29
			[ 1,	 8],
			[ 8,	 8],
			[ 8,	12], # thief							 32
			[ 1,	 8],
			[ 8,	 4], # ship								 34
			[ 1,	11],
			[ 8,	 1],
			[ 8,	12], # reed gatherer					 37
			[ 1,	 8],
			[ 8,	15],
			[ 8,	12],
			[ 8,	12], # tax collector					 41
			[ 1,	 8],
			[ 8,	12], # cartpusher						 43
			[ 1,	 8],
			[ 8,	12], # hunter							 45
			[ 1,	 8],
			[ 8,	12], #	-- hunting						 47
			[ 8,	12], #	-- collecting					 48
			[ 8,	12], #	-- attacking					 49
			[ 8,	18], #	-- pick up						 50
			[ 8,	12], #	-- returning					 51
			[ 8,	12], # donkey							 52
			[ 1,	 8],
			[ 8,	12], # archer							 54
			[ 1,	 8],
			[ 8,	12],
			[ 8,	12], # teacher							 57
			[ 1,	 8],
			[ 8,	12], # waterguy							 69
			[ 1,	 8],
			[ 8,	12], # archer2							 61
			[ 1,	 8],
			[ 8,	12],
			[ 8,	12], # infantry							 64
			[ 1,	 8],
			[ 8,	12],
			[ 8,	12], # charioteer						 67
			[ 1,	 8],
			[ 8,	12],
			[ 8,	 1],
			[ 8,	12], # physician						 71
			[ 1,	 8],
			[ 8,	12], # woodcutter						 73
			[ 1,	 8],
			[ 8,	12],
			[ 8,	12],
			[ 8,	 1], # cart								 77
			[ 8,	 3], # -- grain							 78
			[ 8,	 3], # -- meat							 79
			[ 8,	 3], # -- lettuce						 80
			[ 8,	 3], # -- chickpeas						 81
			[ 8,	 3], # -- pomegrenate					 82
			[ 8,	 3], # -- figs							 83
			[ 8,	 3], # -- fish							 84
			[ 8,	 3], # -- gamemeat						 85
			[ 8,	 3], # -- straw							 86
			[ 8,	 3], # -- weapon						 87
			[ 8,	 3], # -- clay							 88
			[ 8,	 3], # -- bricks						 89
			[ 8,	 3], # -- pottery						 90
			[ 8,	 3], # -- barley						 91
			[ 8,	 3], # -- beer							 92
			[ 8,	 3], # -- flax							 93
			[ 8,	 3], # -- linen							 94
			[ 8,	 3], # -- gems							 95
			[ 8,	 3], # -- luxury goods					 96
			[ 8,	 3], # -- wood							 97
			[ 8,	 3], # -- gold							 98
			[ 8,	 3], # -- reeds							 99
			[ 8,	 3], # -- paper							100
			[ 8,	 1], # -- stone							101
			[ 8,	 1], # -- limestone						102
			[ 8,	 1], # -- granite						103
			[ 8,	 1], # -- marble						104
			[ 8,	 3], # -- chariots						105
			[ 8,	 1], # -- empty (stone pullers)			106
			[ 8,	 3], # -- copper						107
			[ 8,	 1], # -- sandstone						108
			[ 8,	12], # bricklayer						109
			[ 1,	 8],
			[ 8,	23],
			[ 8,	 9],
			[ 8,	12], # chariot horses					113
			[ 1,	25], # seagulls							114
			[ 1,	25],
			[ 8,	12], # laborer							116
			[ 1,	 8],
			[ 8,	13],
			[ 8,	13],
			[ 8,	15],
			[ 8,	12],
			[ 8,	12],
			[ 8,	 4], # merchant ship					123
			[ 1,	11],
			[ 8,	 1],
			[ 8,	12], # dock worker						126
			[ 1,	 8],
			[ 8,	12], # dancer							128
			[ 1,	 8],
			[ 8,	12], # juggler							130
			[ 1,	 8],
			[ 8,	12], # senet							132
			[ 1,	 8],
			[ 8,	 4], # fishing ship						134
			[ 8,	 9],
			[ 1,	11],
			[ 8,	 1],
			[ 8,	 4], # ferry							138
			[ 1,	11],
			[ 8,	 1],
			[ 8,	 4], # warship							141
			[ 1,	11],
			[ 8,	 1],
			[ 8,	 1],
			[ 8,	12], # carpenter						145
			[ 1,	 8],
			[ 8,	 7], # bricklayer -- sculpt down		147
			[ 8,	 7], # -- sculpting standing			148
			[ 8,	 3], # -- ladder						149
			[ 8,	12], # stonemason						150
			[ 1,	 8],
			[ 8,	 7],
			[ 8,	 7],
			[ 8,	 3],
			[ 8,	12], # -- standing						155
			[ 8,	12], # ostrich							156
			[ 1,	 8],
			[ 8,	 7],
			[ 8,	 8],
			[ 8,	 8],
			[ 8,	12], # hyena							161
			[ 8,	 6],
			[ 1,	 6],
			[ 8,	 6],
			[ 8,	 6],
			[ 8,	 1], # cartload							166
			[ 8,	 1], # -- stone							167
			[ 8,	 1], # -- limestone						168
			[ 8,	 1], # -- granite						169
			[ 8,	 1], # -- marble						170
			[ 8,	 1], # -- sandstone						171
			[ 8,	 1], # -- bricks						172
			[ 8,	 1], # -- slanted, empty				173
			[ 8,	 1], # -- slanted, stone				174
			[ 8,	 1], # -- slanted, limestone			175
			[ 8,	 1], # -- slanted, granite				176
			[ 8,	 1], # -- slanted, marble				177
			[ 8,	 1], # -- slanted, sandstone			178
			[ 8,	 1], # -- slanted, bricks				179
			[ 8,	12], # apothecary						180
			[ 1,	 8],
			[ 8,	12], # dentist							182
			[ 1,	 8],
			[ 8,	12], # hunter (bird)					184
			[ 1,	 8],
			[ 8,	12],
			[ 8,	12], # priest (ptah)					187
			[ 1,	 8],
			[ 8,	12], # unused old magistrate			189
			[ 1,	 8],
			[ 8,	12], # musician							191
			[ 1,	 8],
			[ 8,	12], # priest (seth)					193
			[ 1,	 8],
			[ 8,	12], # mortuary							195
			[ 1,	 8],
			[ 8,	12], # priest (osiris)					197
			[ 1,	 8],
			[ 8,	12], # unused old librarian				199
			[ 1,	 8],
			[ 8,	12], # librarian						201
			[ 1,	 8],
			[ 8,	12], # plague							203
			[ 8,	12], # -- puking						204
			[ 1,	 8],
			[ 8,	12], # laborseeker						206
			[ 1,	 8],
			[ 8,	12], # priest (bast)					208
			[ 1,	 8],
			[ 8,	12], # priest (ra)						210
			[ 1,	 8],
			[ 8,	12], # magistrate						212
			[ 1,	 8],
		]
	} }
func get_SG_ANIMS(pak_name: String):
	return _get_table_element(SG_ANIMS, Assets.GAME_SET, pak_name)

const ANIM_LOOKUP = { # this groups together animations into a lookup table for figures, buildings, etc.
	"Pharaoh": {
		"Figures": [
			null, # NONE = 0,
			[14, 15], # IMMIGRANT = 1,
			[2, 3], # EMIGRANT = 2,
			[12, 13], # HOMELESS = 3,
			[43, 44], # CART_PUSHER = 4,
			[206, 207], # LABOR_SEEKER = 5,
			null, #	EXPLOSION = 6,
			[41, 42], # TAX_COLLECTOR = 7,
			[4, 5], # ENGINEER = 8,
			[43, 44], # WAREHOUSEMAN = 9,
			[6, 7, 8], # FIREMAN = 10,
			[], # FORT_JAVELIN = 11,
			[], # FORT_MOUNTED = 12,
			[], # FORT_LEGIONARY = 13,
			[], # FORT_STANDARD = 14,
			[130, 131], # JUGGLER = 15,
			[191, 192], # MUSICIAN = 16,
			[128, 129], # DANCER = 17,
			[132, 133], # SENET_PLAYER = 18,
			[], # TRADE_CARAVAN = 19,
			[123, 124, 125], # TRADE_SHIP = 20,
			[52, 53], # TRADE_CARAVAN_DONKEY = 21,
			[], # PROTESTER = 22,
			[], # CRIMINAL = 23,
			[], # RIOTER = 24,
			[], # FISHING_BOAT = 25,
			[18, 19], # MARKET_TRADER = 26,
			[], # PRIEST = 27,
			[], # SCHOOL_CHILD = 28,
			[57, 58], # TEACHER = 29,
			[201, 202], # LIBRARIAN = 30,
			[182, 183], # DENTIST = 31,
			[71, 72], # PHYSICIAN = 32,
			[180, 181], # APOTHECARY = 33,
			[195, 196], # MORTUARY = 34,
			[], # WORKER = 35,
			[], # MAP_FLAG = 36,
			[], # FLOTSAM = 37,
			[], # DOCKER = 38,
			[16, 17], # MARKET_BUYER = 39,
			[], # PATRICIAN = 40,
			[], # INDIGENOUS_NATIVE = 41,
			[], # TOWER_SENTRY = 42,
			null, #		// ENEMY43_SPEAR = 43,
			null, #		// ENEMY44_SWORD = 44,
			null, #		// ENEMY45_SWORD = 45,
			null, #		// ENEMY46_CAMEL = 46,
			null, #		// ENEMY47_ELEPHANT = 47,
			null, #		// ENEMY48_CHARIOT = 48,
			null, #		// ENEMY49_FAST_SWORD = 49,
			null, #		// ENEMY50_SWORD = 50,
			null, #		// ENEMY51_SPEAR = 51,
			null, #		// ENEMY52_MOUNTED_ARCHER = 52,
			null, #		// ENEMY53_AXE = 53,
			null, #		// ENEMY54_GLADIATOR = 54,
			null, #		// ENEMY_CAESAR_JAVELIN = 55,
			null, #		// ENEMY_CAESAR_MOUNTED = 56,
			null, #		// ENEMY_CAESAR_LEGIONARY = 57,
			null, #		// NATIVE_TRADER = 58,
			[], # ARROW = 59,
			[], # JAVELIN = 60,
			null, # 	// BOLT = 61,
			null, # 	// BALLISTA = 62,
			null, # 	// CREATURE = 63,
			[], # 		// MISSIONARY = 64,
			[], # FISH_GULLS = 65,
			[], # DELIVERY_BOY = 66,
			[], # SHIPWRECK = 67,
			[], # SEAGULLS = 68,
			[156, 157, 158, 159, 160], # OSTRICH = 69,
			[], # ANTELOPE = 70,
			[], # SPEAR = 71,
			null, # 	// HIPPODROME_HORSES = 72,
			[], # HUNTER = 73,
			[0, 1], # 	// HUNTER_ARROW = 74,
			[], # LUMBERJACK = 75,
			[], # FERRY = 76,
			[], # TRANSPORT_SHIP = 77,
			[], # WARSHIP = 78,
			[], # CARPENTER = 79,
			[], # BRICKLAYER = 80,
			[], # STONEMASON = 81,
			[], # CROCODILE = 82,
			[], # HYENA = 83,
			[], # HIPPO = 84,
			[116, 117, 118, 119, 120, 121, 122], # LABORER = 85,
			null, #		// = 86
			[], # WATER_CARRIER = 87,
			[], # POLICEMAN = 88,
			[], # MAGISTRATE = 89,
			[], # REED_GATHERER = 90,
			[], # FESTIVAL_PRIEST = 91,
			null, # 	// = 92
			null, # 	// TRANSPORT_SHIP = 93,
			null, #		// = 94
			[], # FISHING_SPOT = 95,
			null, # 	// LABORER_2 = 96,
			null, #		// = 97
			[], # PLAGUE_GUY = 98,
			[], #	// MILITIA = 99,
			[], #	// WARSHIP_2 = 100,
			null, #		// = 101
			null, #		// = 102
			null, #		// = 103
			null, #		// = 104
			null, #		// = 105
			null, #		// = 106
			null, #		// = 107
			null, #		// = 108
			null, #		// = 109
			[], #	// HUNTER_2 = 110,
			[], # HUNTER_WITH_BIRDS = 111,
			null, #		// PRIEST_2 = 112,
			null, #		// PRIEST_3 = 113,
			null, #		// PRIEST_4 = 114,
			null, #		// PRIEST_5 = 115,
			null, #		// = 116
			null, #		// = 117
			null, #		// = 118
			null, #		// = 119
			null, #		// = 120
		] } }
func get_ANIM_LOOKUP(category: String, i = null):
	var cc = _get_table_element(ANIM_LOOKUP, Assets.GAME_SET, category)
	if cc != null:
		if i == null:
			return cc
		if i >= cc.size():
			return Log.error("get_ANIM_LOOKUP", ERR_DOES_NOT_EXIST, "index '%d' out of bound for anim cache '%s'" % [i, category])
		return cc[i]
	return null

var SPRITES_CACHE = {}
func get_SPRITES_CACHE(anim_name):
	return _get_table_element(SPRITES_CACHE, Assets.GAME_SET, anim_name)
func set_SPRITES_CACHE(anim_name, value) -> bool:
	return _set_table_element(SPRITES_CACHE, Assets.GAME_SET, anim_name, value)

const TILESETS = {
	"Pharaoh": {
		# these are the STATIC paks that are common to all combinations of enemy, theater, monument era etc.
		# --- so it's "shared" as in shared to all of the above, NOT as in those that use SHARED ID SPACES. 
		"shared": ["Pharaoh_General", "Pharaoh_Terrain", "Expansion"],
		"unloaded": [
			"Pyramid"
		]
	} }
func get_TILESETS(category: String):
	return _get_table_element(TILESETS, Assets.GAME_SET, category)






