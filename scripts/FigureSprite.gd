extends Node2D

var FIGURE_CS = null setget set_figure
onready var SPRITE = $Sprite
onready var SPRITE2 = $AnimatedSprite

var _IDX = null
func set_figure(idx): # this is index into the Figures.figures global array
	_IDX = idx
	FIGURE_CS = Figures.figures[_IDX]
	update_position()
	
	
#	print(FIGURE_CS.test())
#	var a = Enums.
#	for a in Enums.get_property_list():
#		print(a)
	
#	set_sprite()
	
#	print("spawned figure %d at %s ---> %s" % [_IDX, tile, position])

func update_position():
	if FIGURE_CS == null:
		return
	var grid_pos = GameTile.new(FIGURE_CS.get("tile_grid"), false).grid_Vector2
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

#func advance_sprite_animation(anim_frame):
##	var frame_count = SPRITE2.frames.get_frame_count(SPRITE2.animation)
##	if SPRITE2.frame == frame_count - 1:
##		SPRITE2.frame = 0
##	else:
##		SPRITE2.frame += 1
##	SPRITE2.frame = anim_frame
##	print(anim_frame)
#	SPRITE2.frame = FIGURE_CS.anim_frame
func repaint():
	var sprite_group = FIGURE_CS.animation_get_sprite_idx()
	
#	SPRITE2.frame = FIGURE_CS.get("anim_frame")
	SPRITE2.frame = sprite_group[0]

func _ready():
	add_to_group("sprites")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_position()
	if !$CanvasLayer.visible:
		return
	if FIGURE_CS == null:
#		$DEBUG_LABEL.bbcode_text = ""
		$CanvasLayer/DEBUG_LABEL2.bbcode_text = ""
		return
	var debug_text = ""
	var type = FIGURE_CS.get("type") # + rand_seed(Game.tick)[0] % 50
	debug_text += "[color=#ffff00]ID:[/color]       %d\n" % [FIGURE_CS.FIGURE_IDX]
	debug_text += "[color=#ffff00]type:[/color]     %s\n" % [Debug.enum_print_bbcode(Debug.CS_ENUMS.FigureTypes, type)]
	debug_text += "[color=#ffff00]action:[/color]   %d\n" % [FIGURE_CS.get("action_state")]

#	$DEBUG_LABEL.bbcode_text = debug_text
	$CanvasLayer/DEBUG_LABEL2.bbcode_text = debug_text
	$CanvasLayer/DEBUG_LABEL2.rect_position = position

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if FIGURE_CS == null:
			pass
#			print("FigureSprite[%s] free(): FIGURE_CS was null!" % [_IDX])
		else:
#			print("FigureSprite[%s] free(): removing reference from linked Figure.cs object..." % [_IDX])
			FIGURE_CS.FigureSprite = null
