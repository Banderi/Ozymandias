extends Node

# TODO: change this by gameset
const PH_MAP_WIDTH = 228
const PH_MAP_SIZE = PH_MAP_WIDTH * PH_MAP_WIDTH # 228 * 228 = 51984

const TILE_WIDTH = 58
const TILE_HEIGHT = 30
const TILE_SIZE = Vector2(TILE_WIDTH, TILE_HEIGHT)

onready var ROOT_NODE = get_tree().root.get_node("Root")
onready var INGAME_ROOT = ROOT_NODE.get_node("InGame")

onready var TILEMAP_FLAT: TileMap = INGAME_ROOT.get_node("Map_Flat") as TileMap
onready var TILEMAP_ANIM: TileMap = INGAME_ROOT.get_node("Map_Anim") as TileMap

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
enum EdgeFlags {
	MASK_COLUMN = 7,
	COLUMN_0 = 0,
	COLUMN_1 = 1,
	COLUMN_2 = 2,
	COLUMN_3 = 3,
	COLUMN_4 = 4,
	COLUMN_5 = 5,
	#
	MASK_ROW = 56,
	ROW_0 = 0,
	ROW_1 = 8,
	ROW_2 = 16,
	ROW_3 = 24,
	ROW_4 = 32,
	ROW_5 = 56,
	#
	DRAW_TILE = 64,
	NATIVE_LAND = 128
}
enum BitFlags {
	MASK_SIZE = 15,
	SIZE_1 = 0,
	SIZE_2 = 1,
	SIZE_3 = 2,
	SIZE_4 = 3,
	SIZE_5 = 4,
	SIZE_6 = 5,
	SIZE_7 = 6,
	SIZE_8 = 7,
	SIZE_9 = 8,
	#
	CONSTRUCTION = 16,
	ALTERNATE_TERRAIN = 32,
	DELETED = 64,
#    BIT_NO_PLAZA = 127,
	PLAZA_OR_EARTHQUAKE = 128,
#    BIT_NO_CONSTRUCTION_AND_DELETED = 175,
#    BIT_NO_DELETED = 191,
#    BIT_NO_CONSTRUCTION = 239,
#    BIT_NO_SIZES = 240,
}

func set_tileset(flats: TileSet, anims: TileSet): # does this require node setup in tree..?
	TILEMAP_FLAT.tile_set = flats
	TILEMAP_ANIM.tile_set = anims # TODO
func tilesets_load_scenario_specifics(): # TODO: anims?
	if !Assets.add_pak_sprites_into_tileset(TILEMAP_FLAT.tile_set, "Temple_bast.sg3"):
		return false

func set_grid(grid_name, x, y, value): # TODO
	if !(grid_name in grids):
		return false
	grids[grid_name][y][x] = value
	return true

func redraw():
	var _t = Stopwatch.start()
	if !GridsMono.RedrawMap(TILEMAP_FLAT, grids): # around ~360 ms (120 ms afterwards)
		return Log.error(self, GlobalScope.Error.FAILED, "(GridsMono) could not set TileMap")
	Stopwatch.stop(self, _t, "GridsMono -> RedrawMap")

var city_orientation = 0
var city_view_camera_x = 0
var city_view_camera_y = 0

const MAX_BOOKMARKS = 16
var bookmarks = []

var map_width = 0
var map_height = 0
var map_grid_start = 0
var map_border_size = 0

func coords_to_cantor(x, y, grid_width: int = PH_MAP_WIDTH) -> int:
	return int(x) + (grid_width * int(y))
func tile_to_cantor(tile: Vector2, grid_width: int = PH_MAP_WIDTH) -> int:
	return int(tile.x) + (grid_width * int(tile.x))
func cantor_to_x(grid_offset: int, grid_width: int = PH_MAP_WIDTH) -> int:
	return grid_offset % grid_width
func cantor_to_y(grid_offset: int, grid_width: int = PH_MAP_WIDTH) -> int:
	return grid_offset / grid_width

func tile_into_game_area(tile: Vector2, grid_width: int = PH_MAP_WIDTH) -> Vector2:
	
	var x_offset = map_grid_start % grid_width
	var y_offset = map_grid_start / grid_width
	
	return Vector2(tile.x + x_offset, tile.y + y_offset)
func map_to_world(tile: Vector2, game_area: bool) -> Vector2:
	if game_area:
		return TILEMAP_FLAT.map_to_world(tile_into_game_area(tile))
	else:
		return TILEMAP_FLAT.map_to_world(tile)
