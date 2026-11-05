extends Node2D

var figure_data = null setget set_figure
onready var SPRITE = $Sprite
onready var SPRITE2 = $AnimatedSprite

var _IDX = null
func set_figure(idx): # this is index into the Figures.figures global array
	_IDX = idx
	figure_data = Figures.figures[_IDX]
	update_position()
	
	
#	print(figure_data.test())
#	var a = Enums.
#	for a in Enums.get_property_list():
#		print(a)
	
#	set_sprite()
	
#	print("spawned figure %d at %s ---> %s" % [_IDX, tile, position])

func update_position():
	if figure_data == null:
		return
	var tile = Vector2(figure_data.get("tile_x"), figure_data.get("tile_y"))
	var grid_pos = GameTile.new(tile, true).grid_Vector2
#	var oriented_pos = grid_pos
#	match Map.city_orientation:
#		4:
#			oriented_pos = Vector2(Map.PH_MAP_WIDTH - grid_pos.x, Map.PH_MAP_WIDTH - grid_pos.y)
#	var world_pos = Map.map_to_world(oriented_pos)
	var world_pos = Map.map_to_world(Map.correct_orientation(grid_pos))
	position = world_pos + Vector2(-1, 30)

#const animated_sprites = [
#
#]
var sprite_anim_data = null
func set_sprite(filename_sgx, tag_idx, sprite_offset):
	return
	
	var _sprite_anim = [filename_sgx, tag_idx, sprite_offset]
	if sprite_anim_data != _sprite_anim:
	
#		var img_idx = Assets.get_tagged_sg_texture_idx(filename_sgx, tag_idx, sprite_offset)
		var img_idx = Assets.get_tagged_sg_texture_idx("SprMain.sg3", 156, 0)
		var anim = Assets.get_animated_sprite_texture(filename_sgx, img_idx, false)
		
#		var a = Assets.get_tagged_sg_texture("SprMain.sg3", 156, 0, false)
#		print("setting sprite.... tag: %s --- offset: %s --- img: %s --- anim: %s" % [tag_idx, sprite_offset, img_idx, anim])
		
#		if anim != null:
#			sprite_anim_data = _sprite_anim

func advance_sprite_animation(anim_frame):
	var frame_count = SPRITE2.frames.get_frame_count(SPRITE2.animation)
	if SPRITE2.frame == frame_count - 1:
		SPRITE2.frame = 0
	else:
		SPRITE2.frame += 1
	SPRITE2.frame = anim_frame
#	print(anim_frame)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_position()
	if !$CanvasLayer.visible:
		return
	if figure_data == null:
#		$DEBUG_LABEL.bbcode_text = ""
		$CanvasLayer/DEBUG_LABEL2.bbcode_text = ""
		return
	var debug_text = ""
	var type = figure_data.get("type") # + rand_seed(Game.tick)[0] % 50
	debug_text += "[color=#ffff00]ID:[/color]       %d\n" % [figure_data.FIGURE_IDX]
	debug_text += "[color=#ffff00]type:[/color]     %s\n" % [Debug.enum_print_bbcode(Debug.CS_ENUMS.FigureTypes, type)]
	debug_text += "[color=#ffff00]action:[/color]   %d\n" % [figure_data.get("action_state")]

#	$DEBUG_LABEL.bbcode_text = debug_text
	$CanvasLayer/DEBUG_LABEL2.bbcode_text = debug_text
	$CanvasLayer/DEBUG_LABEL2.rect_position = position

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if figure_data == null:
			pass
#			print("FigureSprite[%s] free(): figure_data was null!" % [_IDX])
		else:
#			print("FigureSprite[%s] free(): removing reference from linked Figure.cs object..." % [_IDX])
			figure_data.FigureSprite = null
