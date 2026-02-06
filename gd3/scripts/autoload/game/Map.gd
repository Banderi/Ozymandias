extends Node

const PH_MAP_WIDTH = 228
const PH_MAP_SIZE = PH_MAP_WIDTH * PH_MAP_WIDTH # 228 * 228 = 51984

const TILE_WIDTH = 58
const TILE_HEIGHT = 30
const TILE_SIZE = Vector2(TILE_WIDTH, TILE_HEIGHT)

var data = {}
var grids = {
	"image": [],
	"edge": [],
	"building": [],
	"terrain": [],
	"aqueduct": [],
	"figure": [],
	"bitfields": [],
	"sprite": [],
	"random": [],
	"desirability": [],
	"elevation": [],
	"building_dmg": [],
	"aqueduct_bak": [],
	"sprite_bak": []
}

onready var ROOT_NODE = get_tree().root.get_node("Root")
onready var INGAME_ROOT = ROOT_NODE.get_node("InGame")
onready var MAP_TERRAIN = INGAME_ROOT.get_node("Map") as TileMap

func set_grid(grid_name, x, y, value):
	if grid_name == "image":
		MAP_TERRAIN.set_cell(x, y, value)
	else:
		pass
