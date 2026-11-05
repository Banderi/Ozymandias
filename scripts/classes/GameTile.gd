extends Reference
class_name GameTile

const GRID_LENGTH = 228
var grid_x: int
var grid_y: int
var grid_cantor: int
var grid_Vector2: Vector2
var map_x: int
var map_y: int
var map_cantor: int
var map_Vector2: Vector2

# conversion ops
func _cantor(x, y):
	return x + (GRID_LENGTH * y)
func _x(cantor):
	return cantor % GRID_LENGTH
func _y(cantor):
	return cantor / GRID_LENGTH

# constructors
func _init_fill_commons(map_space: bool):
	if map_space:
		grid_cantor = map_cantor + Map.map_grid_start
		grid_x = _x(grid_cantor)
		grid_y = _y(grid_cantor)
	else:
		map_cantor = grid_cantor - Map.map_grid_start
		map_x = _x(map_cantor)
		map_y = _y(map_cantor)
##		var x_offset = Map.map_grid_start % GRID_LENGTH
##		var y_offset = Map.map_grid_start / GRID_LENGTH
#		match Map.city_orientation:
#			0:
#				map_x = grid_x - _x(Map.map_grid_start)
#				map_y = grid_y - _y(Map.map_grid_start)
#			4:
#				map_x = GRID_LENGTH - grid_x - _x(Map.map_grid_start)
#				map_y = GRID_LENGTH - grid_y - _y(Map.map_grid_start)
##		map_x = grid_x - _x(Map.map_grid_start)
##		map_y = grid_y - _y(Map.map_grid_start)
#		map_cantor = _cantor(map_x, map_y)
##		assert(map_cantor == grid_cantor - Map.map_grid_start)
	grid_Vector2 = Vector2(grid_x, grid_y)
	map_Vector2 = Vector2(map_x, map_y)
func _init_from_coord(x: int, y: int, map_space: bool):
	if map_space:
#		map_x = x
#		map_y = y
#		match Map.city_orientation:
#			0:
#				map_cantor = _cantor(map_x, map_y)
#				grid_cantor = map_cantor + Map.map_grid_start
#				grid_x = _x(grid_cantor)
#				grid_y = _y(grid_cantor)
#			4:
#				grid_x = GRID_LENGTH - map_x - _x(Map.map_grid_start)
#				grid_y = GRID_LENGTH - map_y - _y(Map.map_grid_start)
#				grid_cantor = _cantor(grid_x, grid_y)
#
#				map_cantor = grid_cantor - Map.map_grid_start
		map_x = x
		map_y = y
		map_cantor = _cantor(map_x, map_y)
	else:
		grid_x = x
		grid_y = y
		grid_cantor = _cantor(grid_x, grid_y)
	_init_fill_commons(map_space)
func _init_from_cantor(cantor: int, map_space: bool):
	if map_space:
		map_cantor = cantor
		map_x = _x(map_cantor)
		map_y = _y(map_cantor)
	else:
		grid_cantor = cantor
		grid_x = _x(grid_cantor)
		grid_y = _y(grid_cantor)
	_init_fill_commons(map_space)
func _init(_in, map_space: bool):
	if _in is int:
		_init_from_cantor(_in, map_space)
	elif _in is Array || _in is PoolIntArray:
		if _in.size() != 2:
			Log.error(self, ERR_INVALID_PARAMETER, "Invalid array-type size passed for MapTile construction.")
		_init_from_coord(_in[0], _in[1], map_space)
	elif _in is Vector2:
		_init_from_coord(_in.x, _in.y, map_space)
	else:
		Log.error(self, ERR_INVALID_PARAMETER, "Unrecognized _in type for MapTile construction.")
		_init_from_coord(0, 0, false)

#func _notification(what):
#	if what == NOTIFICATION_PREDELETE:
#		print(1)
