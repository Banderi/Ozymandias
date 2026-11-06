using Godot;
using System;
using System.IO;
using GodotArray = Godot.Collections.Array;
using GodotDictionary = Godot.Collections.Dictionary;

public class Grids_mono : Node
{
	// Member variables here, example:
	public override void _Ready() {
		GD.Print("*** MONO: GridsMono loaded: " + this);
	}

	// Log.error(...)
	protected void PrintError(string Message, int Err = 1) {
		Globals.Log.Call("error", this, 1, Message);
	}
	protected void PrintGeneric(string Message) {
		Globals.Log.Call("generic", this, Message);
	}

	public int GRID_SIZE;
	public int MAP_WIDTH; // these are from the game's Scenario settings --- they are DOUBLE the rectangle size!!
	public int MAP_HEIGHT;

	// const int PH_MAP_WIDTH = 228;
	// const int PH_MAP_SIZE = PH_MAP_WIDTH * PH_MAP_WIDTH; // 228 * 228 = 51984

	// enum ScribeFormat {
	// 	i8,
	// 	i16,
	// 	i32,
	// 	u8,
	// 	u16,
	// 	u32,
	// 	ascii,
	// 	utf8,
	// 	raw
	// }


	// bool map_tile_is_inside_diamond(int x, int y, int map_size) {
		
	// 	int delta_x = x - MAP_CENTER;
	// 	int delta_y = y - MAP_CENTER;

	// 	// if (delta_x >= 0) {
	// 	// 	if (delta_y >= 0)
	// 	// 		return (Math.Abs(delta_x) + Math.Abs(delta_y) <= map_size / 2);
	// 	// 	return x - y <= GRID_MAP_END_Y_MINUS_ONE - GRID_CENTER_X_MINUS_ONE;
	// 	// }
	// 	// if (GRID_CENTER_X_MINUS_ONE < y) {
	// 	// 	return GRID_CENTER_Y_MINUS_ONE - GRID_MAP_END_X_MINUS_ONE <= x - y;
	// 	// }
	// 	// return GRID_Y_PADDING + GRID_CENTER_X_MINUS_ONE <= x + y;


	// 	if (delta_x >= 0)
	// 		if (delta_y >= 0)
	// 			return (Math.Abs(delta_x) + Math.Abs(delta_y) <= map_size / 2);
	// 		else
	// 			return (Math.Abs(delta_x) - Math.Abs(delta_y) <= map_size / 2);
	// 	else
	// 		if (delta_y >= 0)
	// 			return (Math.Abs(delta_x) - Math.Abs(delta_y) <= map_size / 2);
	// 		else
	// 			return (Math.Abs(delta_x) + Math.Abs(delta_y) <= map_size / 2);
	// }
	public bool TileIsInsideMap(int x, int y) {
		// Tile-center offset from the grid center, doubled to stay integer.
		// int dx2 = 2 * x + 1 - GRID_X;
		// int dy2 = 2 * y + 1 - GRID_Y;
		int dx2 = 2 * x + 1 - GRID_SIZE;
		int dy2 = 2 * y + 1 - GRID_SIZE;

		// Top-left/bottom-right sides run along (1,-1), so the extent across
		// them is measured by dx - dy. Top-right/bottom-left sides run along
		// (1,1), so their extent is measured by dx + dy.
		// |dx - dy| <= cellsX  <=>  |dx2 - dy2| <= 2*cellsX   (likewise for Y)
		return Math.Abs(dx2 - dy2) <= 2 * MAP_WIDTH / 2
			&& Math.Abs(dx2 + dy2) <= 2 * MAP_HEIGHT / 2;
	}
	
	// update entire TileMap with grid data
	public bool RedrawMap(TileMap map, GodotDictionary grids, Enums.Directions orientation) {
		try{

		var igrid_images = ((GridInterface)grids["images"]).grid;
		var igrid_edge = ((GridInterface)grids["edge"]).grid;
		Grid<uint> grid_images = (Grid<uint>)igrid_images;
		Grid<sbyte> grid_edge = (Grid<sbyte>)igrid_edge;


		// GodotArray grid_images = (GodotArray)grids["images"];
		for (int y = 0; y < GRID_SIZE; y++)
		{
			// GodotArray row = (GodotArray)grid_images[y];
			for (int x = 0; x < GRID_SIZE; x++)
			{
				int cell_x = x;
				int cell_y = y;
				switch (orientation) {
					case Enums.Directions.CITY_90_DEG:
						cell_x = y; cell_y = GRID_SIZE - x - 1;
						break;
					case Enums.Directions.CITY_180_DEG:
						cell_x = GRID_SIZE - x - 1; cell_y = GRID_SIZE - y - 1;
						break;
					case Enums.Directions.CITY_270:
						cell_x = GRID_SIZE - y - 1; cell_y = x;
						break;
				}

				map.SetCell(cell_x, cell_y, -1);
				if (!TileIsInsideMap(x, y)){
					continue;}
				// int image = (int)row[x];
				// int image = (int)( (GodotArray)( (GodotArray)grids["images"] )[y] )[x];
				// int edge = (int)( (GodotArray)( (GodotArray)grids["edge"] )[y] )[x];
				// int image = (int)((GridInterface)grids["images"]).Get(x, y);
				// int edge = (int)((GridInterface)grids["edge"]).Get(x, y);
				// int image = (int)((GridInterface)grids["images"]).grid.GetValue(x, y);
				// int edge = (int)((GridInterface)grids["edge"]).grid.GetValue(x, y);
				// int image = (int)((Grid<int>)((GridInterface)grids["images"]).grid)[x, y];
				// int edge = (int)((Grid<int>)((GridInterface)grids["edge"]).grid)[x, y];
				int image = (int)grid_images[x, y];
				int edge = (int)grid_edge[x, y];
				// Enums.EdgeFlags edge = (Enums.EdgeFlags)( (GodotArray)( (GodotArray)grids["edge"] )[y] )[x];
				// int bitfields = (int)( (GodotArray)( (GodotArray)grids["bitfields"] )[y] )[x];

				
				if (((Enums.EdgeFlags)edge & Enums.EdgeFlags.DRAW_TILE) == Enums.EdgeFlags.DRAW_TILE)
					map.SetCell(cell_x, cell_y, image);
				// else
				// 	map.SetCell(cell_x, cell_y, -1);


				// if (map_tile_is_inside_diamond(x, y, 84))
				// 	map.SetCell(x, y, (int)( (GodotArray)( (GodotArray)grids["images"] )[y] )[x]);
				// else
				// 	map.SetCell(x, y, -1);
			}
		}
		return true;
		} catch (Exception e){PrintError(e.ToString()); return false;}
	}
}
