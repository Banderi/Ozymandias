extends Node

const PH_MAP_WIDTH = 228
const PH_MAP_SIZE = PH_MAP_WIDTH * PH_MAP_WIDTH # 228 * 228 = 51984

const TILE_WIDTH = 58
const TILE_HEIGHT = 30
const TILE_SIZE = Vector2(TILE_WIDTH, TILE_HEIGHT)

onready var ROOT_NODE = get_tree().root.get_node("Root")
onready var INGAME_ROOT = ROOT_NODE.get_node("InGame")

var data = {}
onready var grids = {
	"image": INGAME_ROOT.get_node("Map_Flat") as TileMap, # testing!
	"edge": null,
	"building": [],
	"terrain": null,
	"aqueduct": null,
	"figure": null,
	"bitfields": null,
	"sprite": null,
	"random": null,
	"desirability": null,
	"elevation": null,
	"building_dmg": null,
	"aqueduct_bak": null,
	"sprite_bak": null,
	
	"fertility": null,
	"vegetation_growth": null,
	"unk_grid03": null,
	"unk_grid04": null,
	"moisture": null
}

var tileset_image = null

func set_tileset(grid_name, tileset: TileSet):
	if !(grid_name in grids):
		return false
	grids[grid_name].tile_set = tileset
	return true
func set_grid(grid_name, x, y, value):
	if !(grid_name in grids):
		return false
	grids[grid_name].set_cell(x, y, value)
	return true

var city_orientation = 0
var city_view_camera_x = 0
var city_view_camera_y = 0

const MAX_BOOKMARKS = 16
var bookmarks = []

func _ready():
	yield(Assets, "ready")
	set_tileset("image", tileset_image)
