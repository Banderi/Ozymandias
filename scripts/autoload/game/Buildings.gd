extends Node

const MAX_BUILDINGS = 4000
const MAX_STORAGE_YARDS = 200

var buildings = []

var corrupt_house_coords_repaired = []
var corrupt_house_coords_deleted = []

var highest_id
var highest_id_ever = 0
var creation_highest_id = 0
var burning_buildings_list_info = 0
var burning_buildings_size = 0

var storage_yards_settings = []




# building C# objects
func init_building_stack(): # prepare array of building objects
	if buildings != []:
		Log.warning(self, "Attempting to re-init non-empty Buildings stack. Clearing...")
		buildings = []
	var BUILDING_CS = load("res://scripts/mono/" + Assets.GAME_SET + "/Building.cs")
	for i in MAX_BUILDINGS:
		buildings.push_back(BUILDING_CS.new(i))
	assert(buildings.size() == MAX_BUILDINGS)
func spawn(): # TODO
	pass

# scribe
func enscribe_buildings():
	Scribe.push_compressed(MAX_BUILDINGS * 264)
	var _t = Stopwatch.start()
	var _empty = 0
	for i in MAX_BUILDINGS:
		var _p = ScribeMono.GetPosition()
		assert(_p % 264 == 0)
		var building = buildings[i]
		building.Fill() # 3~5 ms compared to 30~50 ms with ScribeMono
		if !building.in_use():
			_empty += 1

	print("buildings: %d (%d empty)    ms taken: %d" % [
		MAX_BUILDINGS - _empty,
		_empty,
		Stopwatch.query(_t)
	])
	Scribe.pop_compressed()

#func _enter_tree():
#	init_building_objs()
