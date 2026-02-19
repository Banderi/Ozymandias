extends Node2D

var figure_data = null setget set_figure
onready var SPRITE = $Sprite
onready var SPRITE2 = $AnimatedSprite

func set_figure(idx): # this is index into the Figures.figures global array
	figure_data = Figures.figures[idx]
	var tile = Vector2(figure_data.getData("tile_x"), figure_data.getData("tile_y"))
	var world_pos = Map.map_to_world(tile, true)
	position = world_pos + Vector2(-1, 30)
#	print("spawned figure %d at %s ---> %s" % [idx, tile, position])

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
