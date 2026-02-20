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

func _enter_tree():
	var BUILDING_CS = load("res://scripts/mono/Building.cs")
	for i in MAX_BUILDINGS: # prepare array of figure objects
		buildings.push_back(BUILDING_CS.new(i))
func _ready():
	assert(buildings.size() == MAX_BUILDINGS)
