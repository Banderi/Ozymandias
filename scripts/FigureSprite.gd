extends Node2D

var FIGURE_CS = null setget set_figure
onready var SPRITE = $Sprite
onready var SPRITE2 = $AnimatedSprite

var _IDX = null
func set_figure(idx): # this is index into the Figures.figures global array
	_IDX = idx
	FIGURE_CS = Figures.figures[_IDX]
	update_position()
#	print("spawned figure %d at %s ---> %s" % [_IDX, tile, position])

func update_position():
	if FIGURE_CS == null:
		return
	var grid_pos = GameTile.new(FIGURE_CS.get("tile_grid"), false).grid_Vector2
	var world_pos = Map.map_to_world(Map.correct_orientation(grid_pos))
	position = world_pos + Vector2(-1, 30)

const SGX_LOOKUP = [ # this is a temporary dirty thing while I work out on a better system. 
	"Pharaoh_Unloaded.sg3",
	"SprMain.sg3",
	"", # enemy here
	"Pharaoh_General.sg3",
	"Pharaoh_Terrain.sg3",
	"Empire.sg3",
	"SprAmbient.sg3",
	"Pharaoh_Fonts.sg3",
	"", # temple
	"SprMain2.sg3",
	"Expansion.sg3", ]
var sprite_info = PoolIntArray([null, null, null])
func repaint():
	if !is_visible_in_tree():
		return
	var _sprite_info = FIGURE_CS.animation_get_sprite_info()
	if sprite_info == _sprite_info:
		return
	
	# change sprite / animation
	if _sprite_info[1] != sprite_info[1] || _sprite_info[2] != sprite_info[2]:
		var filename_sgx = SGX_LOOKUP[_sprite_info[1]]
		
		var img_idx = Assets.get_tagged_sg_texture_idx(filename_sgx, _sprite_info[2], _sprite_info[0])
		var anim = Assets.get_animated_sprite_texture(filename_sgx, _sprite_info[2], false)
#		var img = _sg_get_img_record(filename_sgx, img_idx)
		pass
	
	# advance frame in animation
	if _sprite_info[0] != sprite_info[0]:
#		SPRITE2.frame = FIGURE_CS.get("anim_frame")
		SPRITE2.frame = _sprite_info[0]
	
	# update local info
	sprite_info = _sprite_info

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
