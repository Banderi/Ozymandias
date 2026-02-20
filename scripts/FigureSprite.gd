extends Node2D

var figure_data = null setget set_figure
onready var SPRITE = $Sprite
onready var SPRITE2 = $AnimatedSprite

func set_figure(idx): # this is index into the Figures.figures global array
	figure_data = Figures.figures[idx]
	var tile = Vector2(figure_data.get("tile_x"), figure_data.get("tile_y"))
	var world_pos = Map.map_to_world(tile, true)
	position = world_pos + Vector2(-1, 30)
	
	
#	print(figure_data.test())
#	var a = Enums.
#	for a in Enums.get_property_list():
#		print(a)
	pass
	
#	print("spawned figure %d at %s ---> %s" % [idx, tile, position])

func update_animation():
	var frame_count = SPRITE2.frames.get_frame_count(SPRITE2.animation)
	if SPRITE2.frame == frame_count - 1:
		SPRITE2.frame = 0
	else:
		SPRITE2.frame += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
