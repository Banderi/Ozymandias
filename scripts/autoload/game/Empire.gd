extends Node

const MAX_EMPIRE_CITIES = 61
const MAX_MAP_OBJECTS = 200
const MAX_TRADE_ROUTES = 20
const MAX_EMPIRE_ROUTES = 50

var empire_map_x = 0
var empire_map_y = 0
var empire_selected_object = 0
var empire_map_objects = []
var empire_routes = []
var empire_cities = []

var trade_prices = []

func enscribe_cities():
	Scribe.push_compressed(MAX_EMPIRE_CITIES * 106)
	for i in MAX_EMPIRE_CITIES:
		Scribe.sync_record([empire_cities, i], TYPE_DICTIONARY)
		# ...
	Scribe.pop_compressed()
func enscribe_objects(file_version):
	Scribe.push_compressed(40 * 32) # unused multiple-empires leftover stuff from C3
	Scribe.pop_compressed()
	
	# empire_map_objects
	Scribe.push_compressed(MAX_MAP_OBJECTS * 98 if file_version >= 160 else 76)
	for i in MAX_MAP_OBJECTS:
		Scribe.sync_record([empire_map_objects, i], TYPE_DICTIONARY)
		# ...
	Scribe.pop_compressed()
	
	# empire_map_routes
	Scribe.push_compressed(MAX_EMPIRE_ROUTES * 324)
	for i in MAX_EMPIRE_ROUTES:
		Scribe.sync_record([empire_routes, i], TYPE_DICTIONARY)
		# ...
	Scribe.pop_compressed()
