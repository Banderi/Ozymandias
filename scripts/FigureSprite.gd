extends Node2D

var figure_data = null setget set_figure
var sprite_id = null

func set_figure(idx): # this is index into the Figures.figure global array
	figure_data = Figures.figures[idx]
	var tile = Vector2(figure_data.tile_x, figure_data.tile_y)
	var world_pos = Map.map_to_world(tile, true)
	position = world_pos + Vector2(-1, 30)
#	print("spawned figure %d at %s ---> %s" % [idx, tile, position])

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
