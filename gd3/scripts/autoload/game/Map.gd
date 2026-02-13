extends Node

const PH_MAP_WIDTH = 228
const PH_MAP_SIZE = PH_MAP_WIDTH * PH_MAP_WIDTH # 228 * 228 = 51984

const TILE_WIDTH = 58
const TILE_HEIGHT = 30
const TILE_SIZE = Vector2(TILE_WIDTH, TILE_HEIGHT)

onready var ROOT_NODE = get_tree().root.get_node("Root")
onready var INGAME_ROOT = ROOT_NODE.get_node("InGame")

onready var TILEMAP_FLAT = INGAME_ROOT.get_node("Map_Flat") as TileMap
onready var TILEMAP_ANIM = INGAME_ROOT.get_node("Map_Anim") as TileMap

var data = {}
onready var grids = {
	"images": [],
	"edge": [],
	"buildings": [],
	"terrain": [],
	"aqueduct": [],
	"figures": [],
	"bitfields": [],
	"sprites": [],
	"random": [],
	"desirability": [],
	
	"elevation": [],
	"building_dmg": [],
	"aqueduct_bak": [],
	"sprite_bak": [],
	
	"fertility": [],
	"vegetation_growth": [],
	"unk_grid03": [],
	"unk_grid04": [],
	"moisture": []
}

enum TerrainFlags {
	TREE =				1,
	ROCK =				2,
	WATER =				4,
	BUILDING =			8,
	SHRUB =				16,
	GARDENS =			32,
	ROAD =				64,
	GROUNDWATER =		128,
	AQUEDUCT =			256,
	ELEVATION =			512,
	RAMP =				1024,
	MEADOW =			2048,
	RUBBLE =			4096,
	WELL_RANGE =		8192,
	WALL =				16384,
	GATEHOUSE =			32768,
	FLOODPLAIN =		65536,
	unk_1 =				131072,
	REEDS =				262144,
	unk_2 =				524288,
	ORE =				1048576,
	unk_3 =				2097152,
	unk_4 =				4194304,
	unk_5 =				8388608,
	IRRIGATED =			16777216,
	DUNE =				33554432,
	DEEP_WATER =		67108864,
	ROAD_FLOODED =		134217728,
	unk_6 =				268435456,
	unk_7 =				536870912,
	unk_8 =				1073741824,
	unk_9 =				2147483648
}

func set_tileset(flats: TileSet, anims: TileSet): # does this require node setup in tree..?
	TILEMAP_FLAT.tile_set = flats
	TILEMAP_ANIM.tile_set = anims
func set_grid(grid_name, x, y, value):
	if !(grid_name in grids):
		return false
#	grids[grid_name].set_cell(x, y, value)
	# TODO
	return true

var city_orientation = 0
var city_view_camera_x = 0
var city_view_camera_y = 0

const MAX_BOOKMARKS = 16
var bookmarks = []
