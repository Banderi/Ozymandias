extends Sprite
class_name FigureSpriteWalker

var FIGURE_ID = -1
var FIGURE_CS = null
func _init(i, cs_ref):
	name = str(i)
	texture = load("res://icon.png")
	FIGURE_ID = i
	FIGURE_CS = cs_ref
	add_to_group("sprites")
	on_tick()

func on_tick():
	if FIGURE_CS == null:
		return
	if !FIGURE_CS.in_use():
		return
	update_position()
	update_sprite()
	pass


func update_position():
	if FIGURE_CS == null:
		return
	var grid_pos = GameTile.new(FIGURE_CS.get("tile_grid"), false).grid_Vector2
	var world_pos = Map.map_to_world(Map.correct_orientation(grid_pos))
#	position = world_pos + Vector2(-1, 30)
	position = world_pos + Vector2(-1, 0)

const SGX_LOOKUP = [ # this is a temporary dirty thing while I work out on a better system. 
	"Pharaoh_Unloaded",
	"SprMain",
	"", # enemy here
	"Pharaoh_General",
	"Pharaoh_Terrain",
	"Empire",
	"SprAmbient",
	"Pharaoh_Fonts",
	"", # temple
	"SprMain2",
	"Expansion", ]
func update_sprite():
	if !FIGURE_CS.ianimation_anim_changed:
		return
	var sprite_props = FIGURE_CS.animation_sprite_poll()
	var sprite_sgx = SGX_LOOKUP[sprite_props[1]]
	var sprite_tag = sprite_props[2]
	
	
	# TODO: move this to C#
	
	var dir = FIGURE_CS.get("direction")
	var frame = FIGURE_CS.get("anim_frame")
	var tile_progress = FIGURE_CS.get("progress_on_tile")
	
#	var sprite_img_idx = null
	if sprite_tag == 0:
		return
	var sprite_img_idx = Assets.get_tagged_sg_texture_idx(sprite_sgx, sprite_tag, frame)
	if sprite_img_idx != null:
#		texture = Assets.get_sg_texture(sprite_sgx, sprite_img_idx, false)
#		texture = Assets.get_gameset_sg_texture(sprite_img_idx, true)
		texture = Assets.get_SG_texture(sprite_sgx, sprite_img_idx, true)
	
	
	
#	match FIGURE_CS.get("type"):
#		_:
#			pass
	
	
	
	
	
	FIGURE_CS.ianimation_anim_changed = false
