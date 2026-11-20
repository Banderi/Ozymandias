extends AnimatedSprite
class_name FigureSprite

var FIGURE_ID = -1
var FIGURE_CS = null
func _init(i, cs_ref):
	name = str(i)
	centered = false
	z_as_relative = true
#	offset = Vector2(0, -30)
	FIGURE_ID = i
	FIGURE_CS = cs_ref
	add_to_group("sprites")
	repaint()
	var c = ColorRect.new()
	c.color = Color(0,1,0,1)
	c.rect_size = Vector2(1, 250)
#	c.rect_position = Vector2(0, -10)
	add_child(c)

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
var TILE_BAND_Z_INDEX = 0
func repaint(force_repaint: bool = false): # TODO: move this to C#?
	if !force_repaint && !FIGURE_CS.needs_repaint:
		return
	
	var sprite_props = FIGURE_CS.sprite_poll()
	
##	if !is_visible_in_tree():
##		return
#	var camera_rect = Game.INGAME_ROOT.get_camera_rect() as Rect2
##	var local_rect = get_viewport_rect()
##	var is_in_view = local_rect.intersects(camera_rect, true)
#	var is_in_view = camera_rect.has_point(position)
##		return
	

	# update tile position
	var tile_grid = sprite_props[6]
	if tile_grid != TILE_GRID || force_repaint:
		var grid_tile = GameTile.new(tile_grid, false).grid_Vector2
		var world_tile = Map.correct_orientation(grid_tile)
		var world_pos = Map.map_to_world(world_tile)
		TILE_BAND_Z_INDEX = world_tile.x + world_tile.y
		TILE_GRID = tile_grid
		position = world_pos + Vector2(-1, 30)
		z_index = TILE_BAND_Z_INDEX
	
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
			if tile_progress != 0:
				match dir:
					0:
						progr_offset = Vector2(2, -1) * tile_progress
					1:
						progr_offset = Vector2(4, 0) * tile_progress
					2:
						progr_offset = Vector2(2, 1) * tile_progress
					3:
						progr_offset = Vector2(0, 2) * tile_progress
					4:
						progr_offset = Vector2(-2, 1) * tile_progress
					5:
						progr_offset = Vector2(-4, 0) * tile_progress
					6:
						progr_offset = Vector2(-2, -1) * tile_progress
					7:
						progr_offset = Vector2(0, -2) * tile_progress
			offset = Vector2(0, -4) + progr_offset
			var tile_half_height = Map.get_grid_tile_size().y / 2
			var tile_z_offset = ((progr_offset.y + tile_half_height) / tile_half_height) # the added tile_half_height (:8) is an arbitrary tweak here.
			z_index = TILE_BAND_Z_INDEX + tile_z_offset
			
			# sprite offset
			if "offsets" in frames.get_meta_list():
				var sprite_offsets = frames.get_meta("offsets")
				var anim_offsets = sprite_offsets.get(anim_s, null)
				if anim_offsets != null:
					offset -= anim_offsets[frame]
			TILE_PROGRESS = tile_progress
#			TILE_PROGRESS = (TILE_PROGRESS + 1) % 15
#			TILE_PROGRESS = 0
	
	get_child(0).rect_position = offset
	FIGURE_CS.needs_repaint = false
