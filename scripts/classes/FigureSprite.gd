extends AnimatedSprite
class_name FigureSprite

var FIGURE_ID = -1
var FIGURE_CS = null
func _init(i, cs_ref):
	name = str(i)
	centered = false
#	offset = Vector2(0, -30)
	FIGURE_ID = i
	FIGURE_CS = cs_ref
	add_to_group("sprites")
	repaint()

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
var TILE_GRID = null
var TILE_PROGRESS = 0
func repaint(force_repaint: bool = false): # TODO: move this to C#
	if !force_repaint && !FIGURE_CS.needs_repaint:
		return
	
	var sprite_props = FIGURE_CS.sprite_poll()
	

	# update tile position
	var tile_grid = sprite_props[6]
	if tile_grid != TILE_GRID || force_repaint:
		var grid_pos = GameTile.new(tile_grid, false).grid_Vector2
		var world_pos = Map.map_to_world(Map.correct_orientation(grid_pos))
		position = world_pos + Vector2(-1, 30)
		TILE_GRID = tile_grid
	
	# set sprite
	var type = sprite_props[0]
	var sgx = SGX_LOOKUP[sprite_props[1]]
	if frames == null:
		frames = Assets.get_animated_sprite(sgx, str("Figures_", type), false)
	if frames == null:
		return
	
	# set animation / action
	var dir = Map.normalize_direction(sprite_props[2])
	var act = sprite_props[3]
	var anim_s = str(act, "_", dir)
	if !frames.has_animation(anim_s):
		anim_s = "default"
	if animation != anim_s:
		animation = anim_s
#		frame = 0 # force reset animation frame to update the offset next up..?
	
	# set animation frame
	if frame != sprite_props[4] || force_repaint:
		frame = sprite_props[4]
	
		# tile progress offset
		var tile_progress = sprite_props[5]
		if tile_progress != TILE_PROGRESS || force_repaint || true:
			
			var progr_offset = Vector2()
			match dir:
				0:
					progr_offset = Vector2(2, -1)
				1:
					progr_offset = Vector2(4, 0)
				2:
					progr_offset = Vector2(2, 1)
				3:
					progr_offset = Vector2(0, 2)
				4:
					progr_offset = Vector2(-2, 1)
				5:
					progr_offset = Vector2(-4, 0)
				6:
					progr_offset = Vector2(-2, -1)
				7:
					progr_offset = Vector2(0, -2)
			offset = Vector2(0, -4) + progr_offset * tile_progress
			
			# sprite offset
			if "offsets" in frames.get_meta_list():
				var sprite_offsets = frames.get_meta("offsets")
				var anim_offsets = sprite_offsets.get(anim_s, null)
				if anim_offsets != null:
					offset -= anim_offsets[frame]
			TILE_PROGRESS = tile_progress
#			TILE_PROGRESS = (TILE_PROGRESS + 1) % 15
#			TILE_PROGRESS = 0
	
	FIGURE_CS.needs_repaint = false
