extends Node

# grid constants
const CONSTS = {
	"Pharaoh": {
		"GRID_SIZE": 228,
		"GRID_TOTAL": 51984, # 228 * 228
		"TILE_W": 60,
		"TILE_H": 30,
	}
}
func get_grid_size():
	return CONSTS[Assets.GAME_SET].GRID_SIZE
func get_grid_cantor_length():
	return CONSTS[Assets.GAME_SET].GRID_TOTAL
func get_grid_center():
	var s = floor(get_grid_size() * 0.5)
	return Vector2(s, s)
func get_grid_tile_size():
	return Vector2(CONSTS[Assets.GAME_SET].TILE_W, CONSTS[Assets.GAME_SET].TILE_H)

onready var ROOT_NODE = get_tree().root.get_node("Root")
onready var INGAME_ROOT = ROOT_NODE.get_node("InGame")
onready var MAP_RENDER_ROOT = INGAME_ROOT.get_node("MapRenderRoot")

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
	DUNES =				33554432,
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

func tilesets_load_scenario_specifics(): # TODO: anims?
	
	# parse various paks (TODO, for now it's just a few selected paks)
	var success = true
#	if !Assets.record_pak_textures("Temple_bast"): success = false
#	if !Assets.record_pak_textures("obelisk5x5a"): success = false
#	if !Assets.record_pak_textures("obelisk3x3a"): success = false
#	if !Assets.record_pak_textures("obelisk_extra"): success = false
	if !Assets.record_pak_textures("Pyramid"): success = false
	
	return success

func redraw():
	var _t = Stopwatch.start()
	if !GridsMono.RedrawMap(city_orientation): # around ~360 ms (120 ms afterwards)
		return Log.error(self, FAILED, "(GridsMono) could not redraw")
	yield(get_tree(), "idle_frame")
	Stopwatch.stop(self, _t, "GridsMono.RedrawMap")

var city_orientation = 0
var city_view_camera_x = 0
var city_view_camera_y = 0

const MAX_BOOKMARKS = 16
var bookmarks = []

var map_width = 0
var map_height = 0
var map_grid_start = 0
var map_border_size = 0

## most coord transformations / calcs have been moved to the MapTile helper class.

func correct_orientation(tile: Vector2) -> Vector2:
	match city_orientation:
		2:
			return Vector2(tile.y, get_grid_size() - tile.x - 1)
		4:
			return Vector2(get_grid_size() - tile.x - 1, get_grid_size() - tile.y - 1)
		6:
			return Vector2(get_grid_size() - tile.y - 1, tile.x)
	return tile
func undo_orientation(tile: Vector2) -> Vector2:
	match city_orientation:
		6:
			return Vector2(tile.y, get_grid_size() - tile.x - 1)
		4:
			return Vector2(get_grid_size() - tile.x - 1, get_grid_size() - tile.y - 1)
		2:
			return Vector2(get_grid_size() - tile.y - 1, tile.x)
	return tile
func normalize_direction(dir: int):
	return (8 + dir - city_orientation) % 8

onready var TILEMAP: TileMap = INGAME_ROOT.get_node("TILEMAP_HELPER") as TileMap
func map_to_world(tile: Vector2) -> Vector2:
	return TILEMAP.map_to_world(tile)
func world_to_map(tile: Vector2) -> Vector2:
	return TILEMAP.world_to_map(tile)

func map_world_center():
	return map_to_world(get_grid_center())
func rotate_left():
	var prev_camera_pos = Game.INGAME_ROOT.camera_position_target
	var map_center = map_world_center()
	var camera_delta = prev_camera_pos - map_center
	city_orientation = (city_orientation + 2) % 8
	redraw()
	Figures.repaint_sprites(true)
	Game.INGAME_ROOT.camera_move_to(map_center + Vector2(2.0 * camera_delta.y, -0.5 * camera_delta.x))
func rotate_right():
	var prev_camera_pos = Game.INGAME_ROOT.camera_position_target
	var map_center = map_world_center()
	var camera_delta = prev_camera_pos - map_center
	city_orientation = (city_orientation - 2 + 8) % 8
	redraw()
	Figures.repaint_sprites(true)
	Game.INGAME_ROOT.camera_move_to(map_center + Vector2(-2.0 * camera_delta.y, 0.5 * camera_delta.x))
func _input(event):
	if Input.is_action_just_pressed("map_rotate_left"):
		rotate_left()
	if Input.is_action_just_pressed("map_rotate_right"):
		rotate_right()
